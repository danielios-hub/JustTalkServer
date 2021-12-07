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
    
    @Children(for: \.$phone)
    var code: [VerificationCode]
    
    init() {}
    
    init(id: UUID? = nil, number: String) {
        self.id = id
        self.number = number
    }
}

extension Phone: Content {}

//MARK: - Input, Output

extension Phone {
    
    struct Input: Content {
        let number: String
    }

    struct Output: Content {
        var isNumberValid: Bool
        var phoneNumber: String
    }
    
}
