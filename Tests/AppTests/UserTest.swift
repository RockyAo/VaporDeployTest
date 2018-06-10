///创建类要属于 AppTest Target

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTest: XCTestCase {
    
    let usersName: String = "Alice"
    let usersUsername: String = "alicea"
    let usersURI: String = "/api/users/"
    var app:Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        super.setUp()
        
        do {
            try Application.reset()
            app = try Application.testable()
            conn = try app.newConnection(to: .psql).wait()
        } catch let error {
            print(" boot test case faild \(error)")
        }
        
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        conn.close()
    }
    
    func testUsersCanBEretrievedFromAPI() throws {
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        
        _ = try User.create(on: conn)
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].userName, usersUsername)
        XCTAssertEqual(users[0].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName, userName: usersUsername, password: "password")
        
        let receivedUser = try app.getResponse(to: usersURI,
                                               method: .POST,
                                               headers: ["Content-type":"application/json"],
                                               data: user,
                                               decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.userName, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].userName, usersUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.userName, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        
        let user = try User.create(on: conn)
        
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        
        let acronym1 = try Acronym.create(short: acronymShort,
                                          long: acronymLong,
                                          user: user,
                                          on: conn)
        
        _ = try Acronym.create(short: "LOL",
                               long: "Laugh Out Loud",
                               user: user,
                               on: conn)
        
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronym1.short)
        XCTAssertEqual(acronyms[0].long, acronym1.long)
    }
}
