//
//  RedisCommands.swift
//  RedShot
//
//  Created by Laurent Gaches on 13/06/2017.
//

import Foundation

extension Redis {

    /// Request for authentication in a password-protected Redis server.
    ///
    /// - Parameter password: The password.
    /// - Returns:  OK status code ( Simple String)
    /// - Throws: if the password no match
    public func auth(password: String) throws -> RedisType {
        return try sendCommand("AUTH", values: [password])
    }

    /// Request for authentication in a password-protected Redis server.
    ///
    /// - Parameter password: The password.
    /// - Returns: true if the password match, otherwise false
    /// - Throws: any other errors
    public func auth(password: String) throws -> Bool {
        do {
            let response: RedisType = try self.auth(password: password)
            guard let resp = response as? String else {
                return false
            }

            return resp == "OK"
        } catch RedisError.response {
            return false
        }
    }

    /// Posts a message to the given channel.
    ///
    /// - Parameters:
    ///   - channel: The channel.
    ///   - message: The message.
    /// - Returns: The number of clients that received the message.
    /// - Throws: something bad happened.
    public func publish(channel: String, message: String) throws -> RedisType {
        return try sendCommand("PUBLISH", values: [channel, message])
    }

    /// Get the value of a key.
    ///
    /// - Parameter key: The key.
    /// - Returns: the value of key, or NSNull when key does not exist.
    /// - Throws: something bad happened.
    public func get(key: String) throws -> RedisType {
        return try sendCommand("GET", values: [key])
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
    /// - Throws: something bad happened.
    public func set(key: String, value: String, exist: Bool? = nil, expire: TimeInterval? = nil) throws -> RedisType {
        var cmd = [key, value]

        if let exist = exist {
            cmd.append(exist ? "XX" : "NX")
        }

        if let expire = expire {
            cmd.append("PX \(Int(expire * 1000.0))")
        }

        return try sendCommand("SET", values: cmd)
    }

    public func sadd(key: String, values: String...) throws -> RedisType {
        var vals = [key]
        vals.append(contentsOf: values)
        return try sendCommand("SADD", values: vals)
    }

    public func smbembers(key: String) throws -> RedisType {
      return try sendCommand("SMEMBERS", values: [key])
    }

    public func lpush(key: String, values: String...) throws -> RedisType {
        var vals = [key]
        vals.append(contentsOf: values)
        return try sendCommand("LPUSH", values: vals)
    }

    public func lpop(key: String) throws -> RedisType {
      return try sendCommand("LPOP", values: [key])
    }

    public func clientSetName(clientName: String) throws -> RedisType {
        return try sendCommand("CLIENT", values: ["SETNAME", clientName])
    }

    public func incr(key: String) throws -> RedisType {
    	return try sendCommand("INCR", values: [key])
    }

    public func select(databaseIndex: Int) throws -> RedisType {
    	return try sendCommand("SELECT", values: ["\(databaseIndex)"])
    }

}
