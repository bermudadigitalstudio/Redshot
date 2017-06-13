//
//  Redis.swift
//  RedShot
//
//  Created by Laurent Gaches on 12/06/2017.
//

import Foundation


public enum RedisError: Error {

    case connection(String)

    case parseResponse
    case typeUnknown
}

public enum TypeIdentifier {
    public static let dollar: UInt8 = 0x24
    public static let plus: UInt8 = 0x2b
    public static let colon: UInt8 = 0x3a
    public static let asterisk: UInt8 = 0x2a

    case simpleString
    case bulkString
    case integer
    case array
}

extension TypeIdentifier: RawRepresentable {
    public typealias RawValue = UInt8

    public init?(rawValue: UInt8) {
        switch rawValue {
        case TypeIdentifier.dollar: self = .bulkString
        case TypeIdentifier.colon: self = .integer
        case TypeIdentifier.plus: self = .simpleString
        case TypeIdentifier.asterisk: self = .array
        default:
            return nil
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .bulkString: return TypeIdentifier.dollar
        case .simpleString: return TypeIdentifier.plus
        case .integer: return TypeIdentifier.colon
        case .array: return TypeIdentifier.asterisk
        }
    }
}

public class Redis {

    private let redisSocket: RedisSocket
    public static let crLf: UInt8 = 0x0D


    public init(hostname: String, port: Int) throws {
        self.redisSocket = try RedisSocket(hostname: hostname, port: port)
    }


    public func get(key: String) throws -> RedisType {
        return try sendCommand("GET \(key)")
    }

    public func push(channel: String, message: String) throws -> RedisType {
        return try sendCommand("PUBLISH \(channel) \"\(message)\"")
    }


    public func set(key: String, value: String) throws -> RedisType {
        return try sendCommand("SET \(key) \(value)")
    }

    @discardableResult private func sendCommand(_ cmd: String) throws -> RedisType {
        let command = "\(cmd)\r\n"
        print("REDIS CMD => \(command)")
        redisSocket.send(string: command)

        let data = redisSocket.read()

        let bytes = data.withUnsafeBytes() {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }

        guard let typeIdentifier = TypeIdentifier(rawValue: bytes[0]) else {
            throw RedisError.typeUnknown
        }

        switch typeIdentifier {
        case .bulkString:
            return BulkString(bytes)
        case .simpleString:
            return SimpleString(bytes)
        case .integer:
            return Integer(bytes)
        case .array:
            throw RedisError.parseResponse
        }
    }
}

public protocol RedisType: CustomStringConvertible  {
    var bytes:[UInt8]  { get }

    init(_ bytes: [UInt8])
}

extension RedisType {
    public var description: String {
        return String(bytes: bytes, encoding: .utf8) ?? "error"
    }
}

public class SimpleString: RedisType {

    public let bytes: [UInt8]
    public required init(_ bytes:[UInt8]) {
        print("Simple String")

        var index = 1
        var buffer = [UInt8]()

        while index < bytes.count, bytes[index] != Redis.crLf {
            buffer.append(bytes[index])
            index += 1
        }

        self.bytes = buffer
    }
}

public class BulkString: RedisType {

    public let bytes: [UInt8]

    //private let bulkSize: Int

    public required init(_ bytes: [UInt8]) {
        print("Bulk String")


        var index = 1
        var buffer = [UInt8]()

        while index < bytes.count, bytes[index] != Redis.crLf {
            buffer.append(bytes[index])
            index += 1
        }

//        self.bulkSize = Int(bytesS)
        // Jump the crLf
        index += 2
        buffer.removeAll(keepingCapacity: true)
        while index < bytes.count, bytes[index] != Redis.crLf {
            buffer.append(bytes[index])
            index += 1
        }

        self.bytes = buffer
    }
}

public class Integer: RedisType {
    public var bytes: [UInt8]

    public required init(_ bytes: [UInt8]) {
        self.bytes = bytes
        var index = 1
        var buffer = [UInt8]()
        while index < bytes.count, bytes[index] != Redis.crLf {
            buffer.append(bytes[index])
            index += 1
        }

        self.bytes = buffer
    }


    public var intValue: Int? {
        guard let strRepresentation = String(bytes: self.bytes, encoding: .utf8) else {
            return nil
        }

        return Int(strRepresentation)
    }
}

public class ArrayResponse: RedisType {
    public var bytes: [UInt8]

    public required init(_ bytes: [UInt8]) {
        self.bytes = bytes
        var index = 1
        var buffer = [UInt8]()

        while index < bytes.count, bytes[index] != Redis.crLf {
            buffer.append(bytes[index])
            index += 1
        }

        guard let str = String(bytes: buffer, encoding: .utf8) else {
            return
        }



    }


}

extension String: RedisType {
    public var bytes: [UInt8] {
        return Array(self.utf8)
    }
}
