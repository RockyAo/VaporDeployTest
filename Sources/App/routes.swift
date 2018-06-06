import Vapor
import Fluent


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    try router.register(collection: AcronymsController())
    try router.register(collection: UsersController())
    try router.register(collection: CategoriesControlelr())
    try router.register(collection: WebsiteController())
}


