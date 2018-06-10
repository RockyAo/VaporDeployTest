import Vapor
import Fluent
import Authentication

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let acronymsRoutes = router.grouped("api","acronyms")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protected = acronymsRoutes.grouped(tokenAuthMiddleware,guardAuthMiddleware)
        protected.post(AcronymCreateData.self, use: createHandler)
        protected.delete(Acronym.parameter, use: deleteHandler)
        protected.put(Acronym.parameter, use: updateAcronymsHandler)
        protected.post(Acronym.parameter,
                            "categories",
                            Category.parameter,
                            use: addCategoriesHandler)
        
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getSpecialItemHandler)
        acronymsRoutes.get("first",use: getFirstItemHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("sorted", use: sortedHanlder)
        acronymsRoutes.get("user", use: getUserHandler)
        acronymsRoutes.get(Acronym.parameter,
                           "categories",
                           use: getCategoriesHandler)
        
       
    }
    
    
    
    //create
    func createHandler(_ req:Request, data: AcronymCreateData) throws -> Future<Acronym> {
        let user = try req.requireAuthenticated(User.self)
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
        return acronym.save(on: req)
    }
    
    //get all
    func getAllHandler(_ req:Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    //get special
    func getSpecialItemHandler(_ req:Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    //get first
    
    func getFirstItemHandler(_ req:Request) throws -> Future<Acronym> {
        
        return Acronym.query(on: req)
            .first()
            .map{
                guard let acronym = $0 else { throw Abort(.notFound) }
                
                return acronym
            }
    }
    
    //change
    func updateAcronymsHandler(_ req:Request) throws -> Future<Acronym>  {
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self), { (acronym, updatedAcronym) in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long

            let user = try req.requireAuthenticated(User.self)
            acronym.userID = try user.requireID()
            return acronym.save(on: req)
        })
    }
  
    
    //delete
    func deleteHandler(_ req:Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: .ok)
    }
    
    //search
    
    func searchHandler(_ req:Request) throws -> Future<[Acronym]> {
        guard let searchItem = req.query[String.self, at: "term"] else { throw Abort(.badRequest) }
        return try Acronym.query(on: req)
            .filter(\.short == searchItem)
            .all()
    }
    

    //sort
    func sortedHanlder(_ req:Request) throws -> Future<[Acronym]> {
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req:Request) throws -> Future<User.Public> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: User.Public.self, { (acronym)  in
                try acronym.user.get(on: req).converToPublic()
            })
    }
    
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Acronym.self),
                           req.parameters.next(Category.self), { (acronym, category) in
            
             let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
                            
             return pivot.save(on: req).transform(to: .created)
        })
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: [Category].self, { (acronym) -> Future<[Category]> in
                return try acronym.categories.query(on: req).all()
            })
    }
}

struct AcronymCreateData: Content {
    let short: String
    let long: String
}
