import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let acronymsRoutes = router.grouped("api","acronyms")
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getSpecialItemHandler)
        acronymsRoutes.get("first",use: getFirstItemHandler)
        acronymsRoutes.put(Acronym.parameter, use: updateAcronymsHandler)
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("sorted", use: sortedHanlder)
        acronymsRoutes.get("user", use: getUserHandler)
    }
    
    
    
    //create
    func createHandler(_ req:Request) throws -> Future<Acronym> {
        return try req.content.decode(Acronym.self)
            .flatMap{
                    return $0.save(on: req)
            }
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
            acronym.userID = updatedAcronym.userID
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
    
    func getUserHandler(_ req:Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: User.self, { (acronym)  in
                try acronym.user.get(on: req)
            })
    }
}
