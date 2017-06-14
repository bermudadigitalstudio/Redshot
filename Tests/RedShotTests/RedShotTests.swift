import XCTest
import RedShot

final class RedShotTests: XCTestCase {

    static var allTests = [
		("testCommand", testCommand),
        ("testInitWithPassword", testInitWithPassword),
        ("testPush", testPush)
    ]

    func testPush() throws {

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

        _ = try redis.push(channel: "ZZ1", message: "{\"channel\":\"dd\",\"msg\":\"sss\"}")

        _ = try redis.push(channel: "ZZ1", message: "Simple String")

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

         _ = try redis.push(channel: "deviceID", message: "hello from swift")

        try redis.sendCommand("DEL mylist")
        let lpush = try redis.lpush(key: "mylist", values: "world", "mundo", "monde", "welt")
        XCTAssertEqual((lpush as? Int), 4)

        _ = try redis.lpop(key: "mylist")

        try redis.sendCommand("DEL myset")
        let sadd = try redis.sadd(key: "myset", values: "world", "mundo", "monde", "welt")

        XCTAssertEqual((sadd as? Int), 4)

        let smembers = try redis.smbembers(key: "myset")
        XCTAssertEqual((smembers as? Array<RedisType>)?.count, 4)

        XCTAssertThrowsError(try redis.sendCommand("TTT"))

        let pong = try redis.sendCommand("PING")
        XCTAssertEqual(pong.description, "PONG")

        try redis.push(channel: "ZZ1", message: "{\"channel\":\"dd\",\"msg\":\"sss\"}")

        XCTAssertTrue(redis.isConnected)
        redis.close()
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
        do {
            let redis = try Redis(hostname: hostname, port: port, password:"password123")
            XCTAssertNotNil(redis)
            XCTAssertTrue(redis.isConnected)
        } catch {
            XCTFail("Init throw an error : \(error.localizedDescription)")
        }
    }
}
