//
// This source file is part of the RedShot open source project
//
// Copyright (c) 2017  Bermuda Digital Studio
// Licensed under MIT
//
// See https://github.com/bermudadigitalstudio/Redshot/blob/master/LICENSE for license information
//
//  Created by Laurent Gaches on 13/06/2017.
//

import Foundation

class Parser {
    let bytes: [UInt8]
    var index = 0
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    func parse() throws -> RedisType {
        guard !bytes.isEmpty else {
            throw RedisError.emptyResponse
        }

        guard let typeIdentifier = TypeIdentifier(rawValue: bytes[index]) else {
            throw RedisError.typeUnknown
        }

        index += 1
        switch typeIdentifier {
        case .error:
            var buffer = [UInt8]()
            while index < bytes.count, bytes[index] != Redis.cr {
                buffer.append(bytes[index])
                index += 1
            }

            let errorMessage = String(bytes: buffer, encoding: .utf8)
            print(errorMessage ?? "no error message")
            throw RedisError.response(errorMessage ?? "Unknown error")
        case .bulkString:
            var buffer = [UInt8]()

            while index < bytes.count, bytes[index] != Redis.cr {
                buffer.append(bytes[index])
                index += 1
            }

            guard let str = String(bytes: buffer, encoding: .utf8), let bulkSize = Int(str) else {
                throw RedisError.parseResponse
            }

            guard bulkSize > 0 else {
                index += 2
                return NSNull()
            }

            index += 2

            buffer.removeAll(keepingCapacity: true)
            while index < bytes.count, bytes[index] != Redis.cr {
                buffer.append(bytes[index])
                index += 1
            }

            guard let value = String(bytes: buffer, encoding: .utf8) else {
                throw RedisError.parseResponse
            }
            index += 2
            return value
        case .simpleString:
            var buffer = [UInt8]()

            while index < bytes.count, bytes[index] != Redis.cr {
                buffer.append(bytes[index])
                index += 1
            }
            guard let value = String(bytes: buffer, encoding: .utf8) else {
                throw RedisError.parseResponse
            }
            return value
        case .integer:
            var buffer = [UInt8]()
            while index < bytes.count, bytes[index] != Redis.cr {
                buffer.append(bytes[index])
                index += 1
            }
            guard let strRepresentation = String(bytes: buffer, encoding: .utf8),
                  let value = Int(strRepresentation) else {
                throw RedisError.parseResponse
            }
            return value
        case .array:
            var buffer = [UInt8]()

            while index < bytes.count, bytes[index] != Redis.cr {
                buffer.append(bytes[index])
                index += 1
            }

            guard let str = String(bytes: buffer, encoding: .utf8), let elementsCount = Int(str) else {
                throw RedisError.parseResponse
            }

            index += 2
            var values = [RedisType]()
            for _ in 0..<elementsCount {
                values.append(try parse())
            }

            return values
        }
    }
}
