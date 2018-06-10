//
//  UsersController.swift
//  App
//
//  Created by Rocky on 2018/5/31.
//

import Foundation
import Vapor
import Crypto

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api","users")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let authGroup = usersRoute.grouped(tokenAuthMiddleware,guardAuthMiddleware)
        authGroup.post("login", use: loginHanlder)
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getSpecialUserHandler)
    
    }
    
    func createHandler(_ req:Request, user:User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).converToPublic()
    }
    
    func getAllHandler(_ req:Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(User.Public.self).all()
    }
    
    func getSpecialUserHandler(_ req:Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).converToPublic()
    }
    
    func getAcronymsHandler(_ req:Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self, { (user) in
                return try user.acronyms.query(on: req).all()
            })
    }
    
    func loginHanlder(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
