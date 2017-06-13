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

    public init(hostname: String, port: Int) throws {
        self.redisSocket = try RedisSocket(hostname: hostname, port: port)
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

}
