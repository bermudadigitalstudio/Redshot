import XCTest
import RedShot

final class RedShotTests: XCTestCase {

    static var allTests = [
		("testCommand", testCommand)
    ]

    override func setUp() {
    }

    func testCommand() throws {

        #if os(Linux)
        let hostname = "redis"
        let port = 6379
        #else
        let hostname = "localhost"
        let port = 32768
        #endif

        let redis = try Redis(hostname: hostname, port: port)

        let resultSet = try redis.set(key: "mycounter", value: "479")
        XCTAssertEqual(resultSet as? String, "OK")

        let result = try redis.get(key: "mycounter")
        XCTAssertEqual(result as? String, "479")

        let pushResult = try redis.push(channel: "deviceID", message: "hello from swift")

        try redis.sendCommand("DEL mylist")
        let lpush = try redis.lpush(key: "mylist", values: "world", "mundo", "monde", "welt")
        XCTAssertEqual((lpush as? Int), 4)

        let lpop = try redis.lpop(key: "mylist")

        try redis.sendCommand("DEL myset")
        let sadd = try redis.sadd(key: "myset", values: "world", "mundo", "monde", "welt")

        XCTAssertEqual((sadd as? Int), 4)

        let smembers = try redis.smbembers(key: "myset")
        XCTAssertEqual((smembers as? Array<RedisType>)?.count, 4)

        XCTAssertThrowsError(try redis.sendCommand("TTT"))

    }

}
