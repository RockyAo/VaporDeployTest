//
//  CategoriesController.swift
//  App
//
//  Created by Rocky on 2018/6/4.
//
import Vapor

struct CategoriesControlelr: RouteCollection {
    
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api","categories")
        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
        categoriesRoute.get(Category.parameter,
                            "acronyms",
                            use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request,category:Category) throws -> Future<Category> {
        return category.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    private func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self)
            .flatMap(to: [Acronym].self, { (category) -> Future<[Acronym]> in
                return try category.acronyms.query(on: req).all()
    
            })
    }
}

