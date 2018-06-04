//
//  UsersController.swift
//  App
//
//  Created by Rocky on 2018/5/31.
//

import Foundation
import Vapor

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api","users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getSpecialUserHandler)
    }
    
    func createHandler(_ req:Request, user:User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAllHandler(_ req:Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getSpecialUserHandler(_ req:Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func getAcronymsHandler(_ req:Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self, { (user) in
                return try user.acronyms.query(on: req).all()
            })
    }
}