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
            .field(.phoneID, .uuid, .required, .references(Phone.schema, .id))
            .unique(on: .phoneID)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(VerificationCode.schema).delete()
    }
}
