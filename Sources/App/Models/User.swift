//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

extension FieldKey {
    static var phoneNumber: Self { "phoneNumber" }
    static var password: Self { "password" }
}

final class User: Model {
    
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: .phoneNumber)
    var phoneNumber: String
    
    @Field(key: .password)
    var password: String
    
    @Children(for: \.$user)
    var code: [VerificationCode]
    
    @Siblings(through: ChatUserPivot.self, from: \.$user, to: \.$chat)
    var chats: [Chat]
    
    init() {}
    
    init(id: UUID? = nil, phoneNumber: String, password: String) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.password = password
    }
}

extension User: Content {}

//MARK: - Input, Output

extension User {
    
    struct Input: Content {
        let number: String
    }

    struct Output: Content {
        var isNumberValid: Bool
        var phoneNumber: String
    }
    
}

extension User: ModelAuthenticatable {
    static let usernameKey: KeyPath<User, Field<String>> = \User.$phoneNumber
    static let passwordHashKey: KeyPath<User, Field<String>> = \User.$password
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
    }
}
