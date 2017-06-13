//
//  RedisSocket.swift
//  RedShot
//
//  Created by Laurent Gaches on 12/06/2017.
//

import Foundation
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class RedisSocket {

    private let socketDescriptor: Int32

    init(hostname: String, port: Int) throws {

        var hints = addrinfo()

        hints.ai_family = AF_UNSPEC
        hints.ai_protocol = Int32(IPPROTO_TCP)
        hints.ai_flags =  AI_PASSIVE
        #if os(Linux)
        hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
        #else
        hints.ai_socktype = SOCK_STREAM
        #endif

        var serverinfo: UnsafeMutablePointer<addrinfo>? = nil

        let status = getaddrinfo(hostname, port.description, &hints, &serverinfo)

        if status != 0 {
            var strError: String

            if status == EAI_SYSTEM {
                strError = String(validatingUTF8: strerror(errno)) ?? "Unknown error code"
            } else {
                strError = String(validatingUTF8: gai_strerror(status)) ?? "Unknown error code"
            }
            print(strError)
        }

        guard let addrInfo = serverinfo else {
            throw RedisError.connection("hostname or port not reachable")
        }

        // Create the socket descriptor
        socketDescriptor = socket(addrInfo.pointee.ai_family, addrInfo.pointee.ai_socktype, addrInfo.pointee.ai_protocol)

        guard socketDescriptor >= 0 else {
            throw RedisError.connection("Cannot Connect")
        }

        // set socket options
        var optval = 1
        #if os(Linux)
        setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, &optval, socklen_t(MemoryLayout<Int>.stride))
        #else
        setsockopt(socketDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &optval, socklen_t(MemoryLayout<Int>.stride))
        #endif

        if status == -1 {
            let strError = String(utf8String:strerror(errno)) ?? "Unknown error code"
            let message = "Setsockopt error \(errno) \(strError)"
            freeaddrinfo(serverinfo)
            close(socketDescriptor)
            print(message)
        }
        #if os(Linux)
        let connStatus = Glibc.connect(socketDescriptor, addrInfo.pointee.ai_addr, addrInfo.pointee.ai_addrlen)
        if connStatus != 0 {
            throw RedisError.connection("can't connect : \(connStatus)")
        }
        #else
        let connStatus = Darwin.connect(socketDescriptor, addrInfo.pointee.ai_addr, addrInfo.pointee.ai_addrlen)
        if connStatus != 0 {
            throw RedisError.connection("can't connect : \(connStatus)")
        }
        #endif

    }

    func read() -> Data {
        var data = Data()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 65_507)
        var readFlags: Int32 = 0
        buffer.initialize(to: 0x0)
        var read = 0
        #if os(Linux)
            read = Glibc.recv(self.socketDescriptor, buffer, Int(UInt16.max), readFlags)
        #else
            read = Darwin.recv(self.socketDescriptor, buffer, Int(UInt16.max), readFlags)
        #endif

        if read > 0 {
            data.append(buffer, count: read)
        }

        return data
    }

    @discardableResult func send(buffer: UnsafeRawPointer, bufferSize: Int) -> Int {
        var sent = 0
        var sendFlags: Int32 = 0
        while sent < bufferSize {
            var s = 0
            #if os(Linux)
                s = Glibc.send(self.socketDescriptor, buffer.advanced(by: sent), Int(bufferSize - sent), sendFlags)
            #else
                s = Darwin.send(self.socketDescriptor, buffer.advanced(by: sent), Int(bufferSize - sent), sendFlags)
            #endif

            sent += s
        }
        return sent
    }

    @discardableResult func send(string: String) -> Int {
       return string.utf8CString.withUnsafeBufferPointer {
            return self.send(buffer: $0.baseAddress!, bufferSize: $0.count - 1)
        }
    }
}
