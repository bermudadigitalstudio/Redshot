//
//  Redis.swift
//  RedShot
//
//  Created by Laurent Gaches on 12/06/2017.
//

import Foundation
import Dispatch

public enum RedisError: Error {

    case connection(String)
    case response(String)
    case parseResponse
    case typeUnknown
    case emptyResponse
    case noAuthorized
}

/// Redis Client
public class Redis {

    private var redisSocket: RedisSocket
    public static let cr: UInt8 = 0x0D
    public static let lf: UInt8 = 0x0A
    private let hostname: String
    private let port: Int
    private var password: String?
    private var subscriber = [String: RedisSocket]()

    /// Test whether or not the client is connected
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
        self.hostname = hostname
        self.port = port
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
        self.password = password
        let _:RedisType = try auth(password: password)
    }

    private func processCmd(_ cmd: String) throws -> RedisType {
        if !self.isConnected {
            redisSocket = try RedisSocket(hostname: self.hostname, port: self.port)
            if let password = password {
                let _: Bool = try self.auth(password: password)
            }
        }

        redisSocket.send(string: cmd)
        let data = redisSocket.read()

        let bytes = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }

        let parser = Parser(bytes: bytes)
        return try parser.parse()
    }

    @discardableResult public func sendCommand(_ cmd: String, values: [String]) throws -> RedisType {
        var command = "*"
        command.append("\(values.count + 1)")
        command.append("\r\n")
        command.append(redisBulkString(value: cmd))

        for value in values {
            command.append(redisBulkString(value: value))
        }

        return try processCmd(command)
    }

    private func redisBulkString(value: String) -> String {
        var buffer = "$"
        let strLength = value.characters.count
        buffer.append("\(strLength)")
        buffer.append("\r\n")
        buffer.append(value)
        buffer.append("\r\n")

        return buffer
    }

    /// Subscribes the client to the specified channel.
    ///
    /// - Parameters:
    ///   - channel: The channel
    ///   - callback:
    /// - Throws: Errors
    public func subscribe(channel: String, callback:@escaping (RedisType?, Error?) -> Void) throws {
        let subscribeSocket = try RedisSocket(hostname: hostname, port: port)

        if let password = self.password {
            subscribeSocket.send(string: "AUTH \(password)\r\n")
            let data = subscribeSocket.read()
            let bytes = data.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
            }

            let parser = Parser(bytes: bytes)
            let authResponse = try parser.parse()
            guard (authResponse as? String) == "OK" else {
                throw RedisError.noAuthorized
            }
        }

        subscriber[channel] = subscribeSocket

        DispatchQueue.global(qos: .userInitiated).async {
            subscribeSocket.send(string: "SUBSCRIBE \(channel)\r\n")
            while subscribeSocket.isConnected {

                let data = subscribeSocket.read()

                let bytes = data.withUnsafeBytes {
                    [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
                }
                if !bytes.isEmpty {
                    do {
                        let parser = Parser(bytes: bytes)
                        callback(try parser.parse(), nil)
                    } catch {
                        callback(nil, error)
                    }
                }
            }
        }
    }

    public func unsubscribe(channel: String) {
        if let socket = subscriber[channel] {
            socket.close()
            subscriber.removeValue(forKey: channel)
        }
    }

    /// Disconnect the client as quickly and silently as possible.
    public func close() {
        self.redisSocket.close()
    }

    deinit {
        self.close()
    }
}
