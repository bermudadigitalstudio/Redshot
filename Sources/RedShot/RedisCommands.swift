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

    /// Add the specified members to the set stored at key.
    /// Specified members that are already a member of this set are ignored.
    /// If key does not exist, a new set is created before adding the specified members.
    /// An error is returned when the value stored at key is not a set.
    ///
    /// - Parameters:
    ///   - key: The key.
    ///   - values: The values
    /// - Returns: Integer reply - the number of elements that were added to the set,
    ///            not including all the elements already present into the set.
    /// - Throws: a RedisError.
    public func sadd(key: String, values: String...) throws -> RedisType {
        var vals = [key]
        vals.append(contentsOf: values)
        return try sendCommand("SADD", values: vals)
    }

    /// Returns all the members of the set value stored at key.
    ///
    /// - Parameter key: The keys.
    /// - Returns: Array reply - all elements of the set.
    /// - Throws: a RedisError.
    public func smbembers(key: String) throws -> RedisType {
      return try sendCommand("SMEMBERS", values: [key])
    }

    /// Insert all the specified values at the head of the list stored at key.
    /// If key does not exist, it is created as empty list before performing the push operations.
    /// When key holds a value that is not a list, an error is returned.
    ///
    /// It is possible to push multiple elements using a single command call just specifying multiple arguments
    /// at the end of the command. Elements are inserted one after the other to the head of the list,
    /// from the leftmost element to the rightmost element.
    /// So for instance the command LPUSH mylist a b c will result into a list containing c as first element,
    /// b as second element and a as third element.
    ///
    /// - Parameters:
    ///   - key: The key.
    ///   - values: the values
    /// - Returns: Integer reply - the length of the list after the push operations.
    /// - Throws: a RedisError.
    public func lpush(key: String, values: String...) throws -> RedisType {
        var vals = [key]
        vals.append(contentsOf: values)
        return try sendCommand("LPUSH", values: vals)
    }

    /// Removes and returns the first element of the list stored at key.
    ///
    /// - Parameter key: The key.
    /// - Returns: Bulk string reply - the value of the first element, or nil when key does not exist.
    /// - Throws: a RedisError.
    public func lpop(key: String) throws -> RedisType {
      return try sendCommand("LPOP", values: [key])
    }

    /// The CLIENT SETNAME command assigns a name to the current connection.
    /// The assigned name is displayed in the output of CLIENT LIST
    /// so that it is possible to identify the client that performed a given connection.
    ///
    /// - Parameter clientName: the name to assign
    /// - Returns: Simple string reply - OK if the connection name was successfully set.
    /// - Throws: a RedisError
    public func clientSetName(clientName: String) throws -> RedisType {
        return try sendCommand("CLIENT", values: ["SETNAME", clientName])
    }

    /// Increments the number stored at key by one.
    /// If the key does not exist, it is set to 0 before performing the operation.
    /// An error is returned if the key contains a value of the wrong type
    /// or contains a string that can not be represented as integer.
    /// This operation is limited to 64 bit signed integers.
    /// Note: this is a string operation because Redis does not have a dedicated integer type.
    /// The string stored at the key is interpreted as a base-10 64 bit signed integer to execute the operation.
    /// Redis stores integers in their integer representation, so for string values that actually hold an integer,
    /// there is no overhead for storing the string representation of the integer.
    ///
    /// - Parameter key: The key.
    /// - Returns: Integer reply - the value of key after the increment
    /// - Throws: a RedisError
    public func incr(key: String) throws -> RedisType {
    	return try sendCommand("INCR", values: [key])
    }

    /// Select the Redis logical database having the specified zero-based numeric index.
    /// New connections always use the database 0.
    ///
    /// - Parameter databaseIndex: the index to select.
    /// - Returns: A simple string reply OK if SELECT was executed correctly.
    /// - Throws: a RedisError.
    public func select(databaseIndex: Int) throws -> RedisType {
    	return try sendCommand("SELECT", values: ["\(databaseIndex)"])
    }

    /// Sets field in the hash stored at key to value.
    /// If key does not exist, a new key holding a hash is created.
    /// If field already exists in the hash, it is overwritten.
    ///
    /// - Parameters:
    ///   - key: The key.
    ///   - field: The field in the hash.
    ///   - value: The value to set.
    /// - Returns: Integer reply, specifically:
    ///            1 if field is a new field in the hash and value was set.
    ///            0 if field already exists in the hash and the value was updated.
    /// - Throws:  a RedisError
    public func hset(key: String, field: String, value: String) throws -> RedisType {
        return try sendCommand("HSET", values: [key, field, value])
    }

    /// Returns the value associated with `field` in the hash stored at `key`.
    ///
    /// - Parameters:
    ///   - key: The key.
    ///   - field: The field in the hash
    /// - Returns: Bulk string reply: the value associated with field, or nil when field is not present in the hash
    ///            or key does not exist.
    /// - Throws: a RedisError
    public func hget(key: String, field: String) throws -> RedisType {
        return try sendCommand("HGET", values: [key, field])
    }

    /// Returns all fields and values of the hash stored at key.
    ///
    /// - Parameter key: The key.
    /// - Returns: a dictionary.
    /// - Throws: a RedisError
    public func hgetAll(key: String) throws -> [String: String] {
        var dictionary: [String: String] = [:]
        if let result = try sendCommand("HGETALL", values: [key]) as? Array<String> {
            let tuples = stride(from: 0, to: result.count, by: 2).map { num in
                return (result[num], result[num + 1])
            }
            for (key, value) in tuples {
                dictionary[key] = value
            }
            return dictionary
        } else {
            throw RedisError.emptyResponse
        }
    }
}
