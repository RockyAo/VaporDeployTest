import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.post("api","acronyms") { (req:Request) -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap({ (acronym)  in
                return acronym.save(on: req)
            })
    }
}
