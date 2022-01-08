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
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Message.schema).delete()
    }
}
