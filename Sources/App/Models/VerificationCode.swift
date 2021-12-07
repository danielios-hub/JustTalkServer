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
    static var phoneID: Self { "phoneID" }
}

final class VerificationCode: Model {
    
    static let schema: String = "PhoneCode"
    
    @ID
    var id: UUID?
    
    @Field(key: .code)
    var code: String
    
    @Parent(key: .phoneID)
    var phone: Phone
    
    init() {}
    
    init(id: UUID? = nil, code: String, phoneID: Phone.IDValue) {
        self.id = id
        self.code = code
        self.$phone.id = phoneID
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
        var code: String
    }
    
}
