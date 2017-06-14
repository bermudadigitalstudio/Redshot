//
//  Redis.swift
//  RedShot
//
//  Created by Laurent Gaches on 12/06/2017.
//

import Foundation

public enum RedisError: Error {

    case connection(String)
    case response(String)
    case parseResponse
    case typeUnknown
    case emptyResponse
}

public class Redis {

    private let redisSocket: RedisSocket
    public static let cr: UInt8 = 0x0D
    public static let lf: UInt8 = 0x0A

    public var isConnected: Bool {
        return self.redisSocket.isConnected
    }

    /// Initializes a `Redis` instance and connects to a Redis server.
    ///
    /// - Parameters:
    ///   - hostname: the server hostname or IP address.
    ///   - port: the port number.
    /// - Throws: if the client can't connect
    public required init(hostname: String, port: Int) throws {
        self.redisSocket = try RedisSocket(hostname: hostname, port: port)
    }

    /// Initializes a `Redis` instance and connects to a Redis server with a password.
    ///
    /// - Parameters:
    ///   - hostname: the server hostname or IP address.
    ///   - port: the port number.
    ///   - password: The password.
    /// - Throws: if the client can't connect
    public convenience init(hostname: String, port: Int, password: String) throws {
        try self.init(hostname: hostname, port: port)

        let _:RedisType = try auth(password: password)
    }

    @discardableResult public func sendCommand(_ cmd: String) throws -> RedisType {
        let command = "\(cmd)\r\n"
        redisSocket.send(string: command)

        let data = redisSocket.read()

        let bytes = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }

        let parser = Parser(bytes: bytes)
        return try parser.parse()
    }

    public func sendArrayCommand(_ cmd: String, key: String, values: [String]) throws -> RedisType {
        var command = "\(cmd) \(key)"
        for value in values {
            command.append(" \"\(value)\"")
        }

        return try sendCommand(command)
    }

    public func close() {
        self.redisSocket.close()
    }

    deinit {
        self.close()
    }
}
