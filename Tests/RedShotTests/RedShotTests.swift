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

import XCTest
import RedShot

final class RedShotTests: XCTestCase {

    static var allTests = [
        ("testComplexString", testComplexString),
        ("testCommand", testCommand),
        ("testInitWithPassword", testInitWithPassword),
        ("testPush", testPush),
        ("testSubscribe", testSubscribe),
        ("testUnsubscribe", testUnsubscribe),
        ("testIncrement", testIncrement),
        ("testSelect", testSelect),
        ("testhset", testhset)
    ]

    func testSubscribe() throws {
        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        let redis = try Redis(hostname: hostname, port: port, password:"password123")

        let expectation = self.expectation(description: "Subscribe")

        try redis.subscribe(channel: "ZZ1", callback: { response, _ in

            if let resp = response as? Array<RedisType> {
                if resp[0].description == "message" {
                    XCTAssertEqual(resp[2].description, "hello")
                    expectation.fulfill()
                }
            }
        })

        sleep(2)
        let sent = try redis.publish(channel: "ZZ1", message: "hello")
        XCTAssertEqual(sent as? Int, 1)
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUnsubscribe() {
        do {
            #if os(Linux)
                let hostname = "redis"
                let port = 6379
            #else
                let hostname = "localhost"
                let port = 6379
            #endif

            let redis = try Redis(hostname: hostname, port: port, password:"password123")

            try redis.subscribe(channel: "ZX81", callback: { _, _ in

            })

            sleep(2)
            let receiver1 = try redis.publish(channel: "ZX81", message: "message")
            XCTAssertEqual(receiver1 as? Int, 1)

            redis.unsubscribe(channel: "ZX81")

            sleep(2)
            let receiver2 = try redis.publish(channel: "ZX81", message: "message")
            XCTAssertEqual(receiver2 as? Int, 0)
        } catch {
            XCTFail(error.localizedDescription)
        }

    }

    func testPush() throws {

        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        let redis = try Redis(hostname: hostname, port: port)
        let authResp: Bool = try redis.auth(password: "password123")
        XCTAssertTrue(authResp)

        _ = try redis.publish(channel: "ZZ1", message: "{\"channel\":\"dd\",\"msg\":\"sss\"}")

        _ = try redis.publish(channel: "ZZ1", message: "Simple String")

        XCTAssertTrue(redis.isConnected)
        redis.close()
    }

    func testCommand() throws {

        #if os(Linux)
        let hostname = "redis"
        let port = 6379
        #else
        let hostname = "localhost"
        let port = 6379
        #endif

        let redis = try Redis(hostname: hostname, port: port)

        let failedAuth: Bool = try redis.auth(password: "hello")
        XCTAssertFalse(failedAuth)

        let authResp: Bool = try redis.auth(password: "password123")
        XCTAssertTrue(authResp)

        let resultSet = try redis.set(key: "mycounter", value: "479")
        XCTAssertEqual(resultSet as? String, "OK")

        let result = try redis.get(key: "mycounter")
        XCTAssertEqual(result as? String, "479")

        let unknownKey = try redis.get(key: "unknown123")
        XCTAssertNotNil(unknownKey as? NSNull)

         _ = try redis.publish(channel: "deviceID", message: "hello from swift")

        try redis.sendCommand("DEL", values: ["mylist"])
        let lpush = try redis.lpush(key: "mylist", values: "world", "mundo", "monde", "welt")
        XCTAssertEqual((lpush as? Int), 4)

        let lpopResult = try redis.lpop(key: "mylist")
        XCTAssertEqual(lpopResult as? String, "welt")

        try redis.sendCommand("DEL", values: ["myset"])
        let sadd = try redis.sadd(key: "myset", values: "world", "mundo", "monde", "welt")
        XCTAssertEqual((sadd as? Int), 4)

        let smembers = try redis.smbembers(key: "myset")
        XCTAssertEqual((smembers as? Array<RedisType>)?.count, 4)

        XCTAssertThrowsError(try redis.sendCommand("TTT", values: []))

        let pong = try redis.sendCommand("PING", values: [])
        XCTAssertEqual(pong.description, "PONG")

        let received = try redis.publish(channel: "ZZ1", message: "{\"channel\":\"dd\",\"msg\":\"sss\"}")
        XCTAssertEqual(received as? Int, 0)

        XCTAssertTrue(redis.isConnected)
        redis.close()
    }

    func testComplexString() {
        do {
            #if os(Linux)
                let hostname = "redis"
                let port = 6379
            #else
                let hostname = "localhost"
                let port = 6379
            #endif

            let message = "18:28:13.036 VERBOSE Extensions.init():14 - Request: Request(method: \"GET\", " +
            "path: \"/health\", body: \"\", headers: [(name: \"User-Agent\", " +
            "value: \"Paw/3.1.1 (Macintosh; OS X/10.12.5) GCDHTTPRequest\"), " +
            "(name: \"Connection\", value: \"close\"), (name: \"Host\", value: \"localhost:8000\")]), " +
            "Code: 200, Body: Host: localhost Time: 2017-06-20 16:28:13 +0000\r\n" +
            "Status: Ok Headers: [(name: \"Content-Type\", value: \"application/json\")]"

            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            let push = try redis.publish(channel: "ComplexString", message: message)
            XCTAssertEqual(push as? Int, 0)
        } catch RedisError.response(let response) {
            XCTFail(response)
        } catch {
            print(error.localizedDescription)
        }
    }

    func testInitWithPassword() {
        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        XCTAssertThrowsError(try Redis(hostname: hostname, port: port, password:"Hello"))
        XCTAssertNoThrow(try Redis(hostname: hostname, port: port, password: ""))

        do {
            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            XCTAssertNotNil(redis)
            XCTAssertTrue(redis.isConnected)
        } catch {
            XCTFail("Init throw an error : \(error.localizedDescription)")
        }
    }

    func testClientSetName() {
        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        do {
            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            let setName = try redis.clientSetName(clientName: "REDSHOT")
            XCTAssertEqual(setName as? String, "OK")
        } catch {
            XCTFail("Init throw an error : \(error.localizedDescription)")
        }
    }

    func testIncrement() {
        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        do {
            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            let incrResult = try redis.incr(key: "INCR_KEY")
            XCTAssertEqual(incrResult as? Int, 1)
        } catch {
            XCTFail("Incr throw an error : \(error.localizedDescription)")
        }
    }

    func testSelect() {
        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        do {
            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            let selectResult = try redis.select(databaseIndex: 3)
            XCTAssertEqual(selectResult as? String, "OK")
        } catch {
            XCTFail("Select throw an error : \(error.localizedDescription)")
        }
    }

    func testhset() {
        #if os(Linux)
            let hostname = "redis"
            let port = 6379
        #else
            let hostname = "localhost"
            let port = 6379
        #endif

        do {
            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            let hsetResult = try redis.hset(key: "TEST_HASH", field: "MY_KEY", value: "my value")
            XCTAssertEqual(hsetResult as? Int, 1)
            let hgetResult = try redis.hget(key: "TEST_HASH", field: "MY_KEY")
            XCTAssertEqual(hgetResult as? String, "my value")

            let hgetAllResult = try redis.hgetAll(key: "TEST_HASH")
            XCTAssertEqual(hgetAllResult.count, 1)

        } catch {
            XCTFail("Select throw an error : \(error.localizedDescription)")
        }
    }

}
