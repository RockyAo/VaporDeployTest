import Vapor
import Fluent


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    
    //create
    router.post("api","acronyms") { (req:Request) -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap({ (acronym)  in
                return acronym.save(on: req)
            })
    }
    
    //get all
    router.get("api","acronyms") { (req:Request) -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    //get special
    router.get("api","acronyms",Acronym.parameter) { (req:Request) -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    //change
    router.put("api","acronyms",Acronym.parameter) { (req) -> Future<Acronym> in
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self), { (acronym, updatedAcronym) in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req)
        })
    }
    
    //delete
    router.delete("api","acronyms", Acronym.parameter) { (req:Request) -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: .ok)
    }
    
    //search
    router.get("api","acronyms","search") { (req:Request) -> Future<[Acronym]> in
        
        guard let searchItem = req.query[String.self, at: "term"] else { throw Abort(.badRequest) }
        
        return try Acronym.query(on: req)
            .filter(\.short == searchItem)
            .all()
    }
    
    //get first
    router.get("api","acronyms","first") { (req:Request) -> Future<Acronym> in
        return Acronym.query(on: req)
            .first()
            .map{
                guard let acronym = $0 else { throw Abort(.notFound) }
                return acronym
            }
    }
    
    //sort
    router.get("api","acronyms","sorted") { (req:Request) -> Future<[Acronym]> in
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
}


