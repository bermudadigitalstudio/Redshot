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

    public func set(key: String, value: String) throws -> RedisType {
        return try sendCommand("SET \(key) \(value)")
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
