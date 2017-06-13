//
//  RedisCommands.swift
//  RedShot
//
//  Created by Laurent Gaches on 13/06/2017.
//

import Foundation

extension Redis {

    public func push(channel: String, message: String) throws -> RedisType {
        return try sendCommand("PUBLISH \(channel) \"\(message)\"")
    }

    public func get(key: String) throws -> RedisType {
        return try sendCommand("GET \(key)")
    }


    /// Set key to hold the string value. If key already holds a value, it is overwritten, regardless of its type.
    /// Any previous time to live associated with the key is discarded on successful SET operation.
    ///
    /// - Parameters:
    ///   - key: The key.
    ///   - value: The value to set
    ///   - exist: if true Only set the key if it already exist. if false Only set the key if it does not already exist.
    ///   - expire: If not nil, set the specified expire time, in milliseconds.
    /// - Returns: A simple string reply OK if SET was executed correctly.
    /// - Throws:
    public func set(key: String, value: String, exist: Bool? = nil, expire: TimeInterval? = nil) throws -> RedisType {
        var cmd = "SET \(key) \(value)"

        if let exist = exist {
            cmd.append(exist ? "XX" : "NX")
        }

        if let expire = expire {
            cmd.append("PX \(Int(expire * 1000.0))")
        }

        return try sendCommand(cmd)
    }

    public func sadd(key: String, values: String...) throws -> RedisType {
        return try sendArrayCommand("SADD", key: key, values: values)
    }

    public func smbembers(key: String) throws -> RedisType {
        return try sendCommand("SMEMBERS \(key)")
    }

    public func lpush(key: String, values: String...) throws -> RedisType {
        return try sendArrayCommand("LPUSH", key: key, values: values)
    }

    public func lpop(key: String) throws -> RedisType {
        return try sendCommand("LPOP \(key)")
    }

}
