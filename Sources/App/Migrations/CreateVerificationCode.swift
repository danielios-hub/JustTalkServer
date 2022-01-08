//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

struct CreateVerificationCode: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(VerificationCode.schema)
            .id()
            .field(.code, .string, .required)
            .field(.userID, .uuid, .required, .references(User.schema, .id))
            .unique(on: .userID)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(VerificationCode.schema).delete()
    }
}
