import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms",Acronym.parameter, use: acronymHandler)
        router.get("users",User.parameter, use: userHandler)
        router.get("users", use: allUsersHandler)
    }
    
    func indexHandler(_ req:Request) throws -> Future<View> {
        return Acronym.query(on: req)
            .all()
            .flatMap(to: View.self, { (acronyms) -> Future<View> in
                
                let acronymsData = acronyms.isEmpty ? nil : acronyms
                let context = IndexContext(title: "HomePage", acronyms: acronymsData)
                
                return try req.view().render("index", context)
            })
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self)
            .flatMap({ (acronym) -> Future<View> in
                
                return try acronym.user
                    .get(on: req)
                    .flatMap({ (user) in
                        
                        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                        
                        return try req.view().render("acronym",context)
                    })
            })
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self)
            .flatMap({ (user) -> Future<View> in
                return try user.acronyms
                    .query(on: req)
                    .all()
                    .flatMap({ (acronyms) -> Future<View> in
                        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                        return try req.view().render("user", context)
                    })
            })
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req)
            .all()
            .flatMap({ (users) -> Future<View> in
                let context = AllUsersContext(title: "All Users", users: users)
                return try req.view().render("allUsers", context)
            })
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}
