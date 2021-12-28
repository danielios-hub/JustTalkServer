//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 26/12/21.
//

import Fluent

struct CreateChatUserPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(ChatUserPivot.schema)
            .id()
            .field(.chatID, .uuid, .required,
                   .references(Chat.schema, .id, onDelete: .cascade))
            .field(.phoneID, .uuid, .required, .references(Phone.schema, .id, onDelete: .cascade))
            .create()
        
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(ChatUserPivot.schema).delete()
    }
}
