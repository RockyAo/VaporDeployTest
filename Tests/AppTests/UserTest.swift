///创建类要属于 AppTest Target

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTest: XCTestCase {
    
    func testUserCanBeRetrievedFromAPI() throws {
        
        // 1
        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
        // 2
        var revertConfig = Config.default()
        var revertServices = Services.default()
        var revertEnv = Environment.testing
        // 3
        revertEnv.arguments = revertEnvironmentArgs
        // 4
        try App.configure(&revertConfig, &revertEnv, &revertServices)
        let revertApp = try Application(config: revertConfig,
                                        environment: revertEnv,
                                        services: revertServices)
        try App.boot(revertApp)
        // 5
        try revertApp.asyncRun().wait()
        
        
        //1 定义一些期望值
        let expectedName = "Alice"
        let expectedUsername = "alice"
        
        //2 创建 Application 和 main.Swift里面一样，这里需要使用测试环境
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        
        //3 创建一个数据库的链接
        let conn = try app.newConnection(to: .psql).wait()
        
        //4 创建几个用户用于存入数据库
        let user = User(name: expectedName, userName: expectedUsername)
        
        let savedUser = try user.save(on: conn).wait()
        _ = try User(name: "Luke", userName: "luke").save(on: conn).wait()
        
        //5 创建一个响应类型
        let responder = try app.make(Responder.self)
        
        //6 创建一个HTTPRequest请求
        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
        
        let wrappedRequest = Request(http: request, using: app)
        
        //7 发送请求并获取响应
        let response = try responder.respond(to: wrappedRequest).wait()
        
        //8 解析返回结果
        let data = response.http.body.data
        let users = try JSONDecoder().decode([User].self, from: data!)
        
        //9 比对期望
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, expectedName)
        XCTAssertEqual(users[0].userName, expectedUsername)
        XCTAssertEqual(users[0].id, savedUser.id)
        
        // 关闭数据库
        conn.close()
    }
}
