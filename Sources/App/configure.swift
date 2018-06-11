import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try registerProvider(&services, &config)
    try registerRouter(&services)
    configureMiddlewares(&services)
    configureDatabase(&services, &env)
    configureMigrations(&services)
    registerCommand(&services)
}

/// 注册 Provider
fileprivate func registerProvider(_ services: inout Services, _ config: inout Config) throws {
    
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
}

/// 注册路由
fileprivate func registerRouter(_ services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

/// 配置数据库
fileprivate func configureDatabase(_ services: inout Services, _ env: inout Environment) {
    var databases = DatabasesConfig()
    
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    let databaseName:String
    let databasePort: Int
    
    if env == .testing {
        databaseName = "vapor-test"
        databasePort = 5433
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 5432
    }
    
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort,
        username: username,
        database: databaseName,
        password: password)
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)

}

/// 配置ORM
fileprivate func configureMigrations(_ services: inout Services) {
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    services.register(migrations)
}

/// 配置中间件
fileprivate func configureMiddlewares(_ services: inout Services) {
    
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(FileMiddleware.self)
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
}

/// 注册命令
fileprivate func registerCommand(_ services: inout Services) {
    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)
}
