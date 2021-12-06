//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

final class Phone: Model {
    
    static let schema = "phones"
    
    @ID
    var id: UUID?
    
    @Field(key: "number")
    var number: String
    
    init() {}
    
    init(id: UUID? = nil, number: String) {
        self.id = id
        self.number = number
    }
}

extension Phone: Content {}
