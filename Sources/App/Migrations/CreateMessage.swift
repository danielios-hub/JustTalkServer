//
//  CreateMessage.swift
//  
//
//  Created by Daniel Gallego Peralta on 8/1/22.
//

import Fluent

struct CreateMessage: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(Message.schema)
            .id()
            .field(.chatID, .uuid, .required, .references(Chat.schema, .id, onDelete: .cascade))
            .field(.userID, .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field(.text, .string, .required)
            .field(.date, .datetime, .required)
            .field(.createdAt, .datetime, .required)
            .field(.updatedAt, .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Message.schema).delete()
    }
}
