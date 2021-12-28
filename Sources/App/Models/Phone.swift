//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

extension FieldKey {
    static var number: Self { "number" }
    static var password: Self { "password" }
}

final class Phone: Model {
    
    static let schema = "phones"
    
    @ID
    var id: UUID?
    
    @Field(key: .number)
    var number: String
    
    @Field(key: .password)
    var password: String
    
    @Children(for: \.$phone)
    var code: [VerificationCode]
    
    @Siblings(through: ChatUserPivot.self, from: \.$phone, to: \.$chat)
    var chats: [Chat]
    
    init() {}
    
    init(id: UUID? = nil, number: String, password: String) {
        self.id = id
        self.number = number
        self.password = password
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

extension Phone: ModelAuthenticatable {
    static let usernameKey: KeyPath<Phone, Field<String>> = \Phone.$number
    static let passwordHashKey: KeyPath<Phone, Field<String>> = \Phone.$password
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
    }
}
