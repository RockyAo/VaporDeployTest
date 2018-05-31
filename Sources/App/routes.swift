import Vapor
import Fluent


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    
    let acronymController = AcronymsController()
    
    try router.register(collection: acronymController)
    
    
}


