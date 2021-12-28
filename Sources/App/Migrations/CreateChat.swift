//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 25/12/21.
//

import Fluent

struct CreateChat: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Chat.schema)
            .id()
            .field(.name, .string, .required)
            .field(.imageURL, .string, .required)
            .field(.createdAt, .date, .required)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Chat.schema).delete()
    }
}
