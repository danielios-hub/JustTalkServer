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
    
    @Parent(key: .phoneID)
    var phone: Phone
    
    init() {}
    
    init(id: UUID? = nil, value: String, phoneID: Phone.IDValue) {
        self.id = id
        self.value = value
        self.$phone.id = phoneID
    }
}

extension Token {
    static func generate(for phone: Phone) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, phoneID: phone.requireID())
    }
}

extension Token: ModelTokenAuthenticatable {
    
    static let valueKey: KeyPath<Token, Field<String>> = \Token.$value
    static let userKey: KeyPath<Token, Parent<User>> = \Token.$phone
    
    typealias User = Phone
    
    var isValid: Bool { true }
}
