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

public enum TypeIdentifier {
    public static let dollar: UInt8 = 0x24
    public static let plus: UInt8 = 0x2b
    public static let colon: UInt8 = 0x3a
    public static let asterisk: UInt8 = 0x2a
    public static let minus: UInt8 = 0x2d

    case simpleString
    case bulkString
    case integer
    case array
    case error
}

extension TypeIdentifier: RawRepresentable {
    public typealias RawValue = UInt8

    public init?(rawValue: UInt8) {
        switch rawValue {
        case TypeIdentifier.dollar: self = .bulkString
        case TypeIdentifier.colon: self = .integer
        case TypeIdentifier.plus: self = .simpleString
        case TypeIdentifier.asterisk: self = .array
        case TypeIdentifier.minus: self = .error
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
        case .error: return TypeIdentifier.minus
        }
    }
}

public protocol RedisType: CustomStringConvertible { }

extension Int: RedisType { }

extension String: RedisType { }

extension Array: RedisType { }

extension NSNull: RedisType { }
