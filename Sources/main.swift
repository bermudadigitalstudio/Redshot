import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

let hostname = "localhost"
let port = 32768



let redis = try Redis(hostname: hostname, port: port)

let resultSet = try redis.set(key: "mycounter", value: "479")
print("My counter is set \(resultSet.description) ==")

let result = try redis.get(key: "mycounter")
print("My Counter \(result.description) ++")


let pushResult = try redis.push(channel: "deviceID", message: "hello from swift")
print("push \(pushResult.description)")
