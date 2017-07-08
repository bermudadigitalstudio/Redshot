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

class RedShotPerformanceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPerformanceSetGet() throws {
        self.measure {
            do {
                let hostname = "localhost"
                let port = 6379
                let redis = try Redis(hostname: hostname, port: port, password: "password123")

                var errorCount = 0
                for index in 1...10_000 {

                    do {
                        _ = try redis.set(key: "mycounter\(index)", value: "value_\(index)")
                        _ = try redis.get(key: "mycounter\(index)")
                    } catch {
                        errorCount += 1
                    }
                }
                print("Error :\(errorCount)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func testPerformancePush() throws {
        self.measure {
            do {
                let hostname = "localhost"
                let port = 6379
                let redis = try Redis(hostname: hostname, port: port, password: "password123")
                for index in 1...10_000 {

                    do {
                        _ = try redis.publish(channel: "PERF", message: "value_\(index)")
                    } catch {
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}
