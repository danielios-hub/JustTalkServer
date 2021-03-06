//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 12/12/21.
//

import Vapor
import Fluent

extension FieldKey {
    static var value: Self { "value"}
}

final class Token: Model, Content {
    static let schema: String = "tokens"
    
    @ID
    var id: UUID?
    
    @Field(key: .value)
    var value: String
    
    @Parent(key: .userID)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, userID: user.requireID())
    }
}

extension Token: ModelTokenAuthenticatable {
    
    static let valueKey: KeyPath<Token, Field<String>> = \Token.$value
    static let userKey: KeyPath<Token, Parent<User>> = \Token.$user
    
    //typealias User = User
    
    var isValid: Bool { true }
}
