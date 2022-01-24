//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

extension FieldKey {
    static var code: Self { "code" }
    static var userID: Self { "userID" }
}

final class VerificationCode: Model {
    
    static let schema: String = "PhoneCode"
    
    @ID
    var id: UUID?
    
    @Field(key: .code)
    var code: String
    
    @Parent(key: .userID)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, code: String, userID: User.IDValue) {
        self.id = id
        self.code = code
        self.$user.id = userID
    }
}

extension VerificationCode: Content {}

//MARK: - Input, Output

extension VerificationCode {
    
    struct Input: Content {
        var phone: String
        var code: String
    }

    struct Output: Content {
        var isCodeCorrect: Bool
        var user: User.Public?
        var token: Token?
    }
    
}
