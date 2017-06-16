# RedShot

RedShot is a minimalistic Swift client library for the [Redis](http://redis.io/) database. 

**Redshot is dependency free**. 

[![Language Swift 3](https://img.shields.io/badge/Language-Swift%203-orange.svg)](https://swift.org) ![Platforms](https://img.shields.io/badge/Platforms-Docker%20%7C%20Linux%20%7C%20macOS-blue.svg) [![CircleCI](https://circleci.com/gh/bermudadigitalstudio/Redshot/tree/master.svg?style=shield)](https://circleci.com/gh/bermudadigitalstudio/Redshot/tree/master)

## Getting started
To add **RedShot** in your projects.

Add this in your `Package.swift` :

`.Package(url: "https://github.com/bermudadigitalstudio/Redshot.git", majorVersion: 0)`


You can connect to Redis by instantiating the `Redis` class :

```swift
import RedShot

let redis = try Redis(hostname: "localhost", port: 6379)
```


To connect to a password protected Redis instance, use:

```swift
let redis = try Redis(hostname: "localhost", port: 6379, password: "mypassword")
```

The Redis class exposes methods that are named identical to the commands they execute. The arguments these methods accept are often identical to the arguments specified on the [Redis website](https://redis.io/commands). For instance, `SET` and `GET` commands can be called like this:

```swift
try redis.set(key: "mycounter", value: "479")

let myCounter = try redis.get(key: "mycounter") 
print(myCounter)
```

## Running Unit Tests

RedShot's unit test require a running Redis database with the following values.

Redis instance can be launch with Docker :

`docker run -d -p 6379:6379 redis:latest --requirepass password123`

### Defaults
* `host: "localhost"`
* `port: 6379`



## Source Code Linting

The source code is formatted using [SwiftLint](https://github.com/realm/SwiftLint) and all commits & PRs need to be without any SwiftLint warnings or errors.


## License

RedShot is released under the [MIT License](https://github.com/bermudadigitalstudio/redshot/blob/master/LICENSE).
