//
//  CreatePhone.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Fluent

struct CreateUser: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field(.phoneNumber, .string, .required)
            .field(.password, .string, .required)
            .unique(on: .phoneNumber)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
