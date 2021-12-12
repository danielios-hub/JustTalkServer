//
//  CreatePhone.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Fluent

struct CreatePhone: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Phone.schema)
            .id()
            .field(.number, .string, .required)
            .unique(on: .number)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Phone.schema).delete()
    }
}
