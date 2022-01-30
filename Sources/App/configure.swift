import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let dabasePort: Int = app.environment == .testing ? 5433 : 5432
    let databaseName: String = app.environment == .testing ? "justtalktest_database" : "justtalk_database"
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: dabasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateVerificationCode())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateChat())
    app.migrations.add(CreateChatUserPivot())
    app.migrations.add(CreateMessage())
    
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
    sockets(app)
    
    #if DEBUG
    createTestData(app)
    #endif
}

//docker run --name postgresjusttalk -e POSTGRES_DB=justtalk_database \
//  -e POSTGRES_USER=vapor_username \
//  -e POSTGRES_PASSWORD=vapor_password \
//  -p 5432:5432 -d postgres
//;
//docker run --name postgresjusttalktest -e POSTGRES_DB=justtalktest_database \
//  -e POSTGRES_USER=vapor_username \
//  -e POSTGRES_PASSWORD=vapor_password \
//  -p 5433:5432 -d postgres

#if DEBUG
func createTestData(_ app: Application) {
    guard app.environment != .testing else { return }
    Task {
        let db = app.db
        let users = try! await User.query(on: db).all()
        
        if users.isEmpty {
            let newCode = "1111"
            let hashCode = try Bcrypt.hash(newCode)
            let user = User(phoneNumber: "606646733", password: hashCode, name: "user one")
            let anotherUser = User(phoneNumber: "606646734", password: hashCode, name: "another user")
            
            try await user.save(on: db)
            try await anotherUser.save(on: db)
            
            let chat = Chat(name: "Some chat name", imageURL: "", createdAt: Date())
            try await chat.save(on: db)
            
            try await chat.$participants.attach(user, on: db)
            try await chat.$participants.attach(anotherUser, on: db)
        }
    }
}
#endif
