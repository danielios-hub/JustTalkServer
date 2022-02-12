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
    static var user_name: Self { "name" }
    static var user_image: Self { "image" }
}

final class User: Model, Content {
    
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: .phoneNumber)
    var phoneNumber: String
    
    @Field(key: .password)
    var password: String
    
    @Field(key: .user_name)
    var name: String
    
    @OptionalField(key: .user_image)
    var image: String?
    
    @Children(for: \.$user)
    var code: [VerificationCode]
    
    @Siblings(through: ChatUserPivot.self, from: \.$user, to: \.$chat)
    var chats: [Chat]
    
    init() {}
    
    init(id: UUID? = nil, phoneNumber: String, password: String, name: String = "", image: String? = nil) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.password = password
        self.name = name
        self.image = image
    }
}

//MARK: - Input, Output

extension User {
    
    struct Input: Content {
        let number: String
    }

    struct Output: Content {
        var isNumberValid: Bool
        var phoneNumber: String
    }
    
    struct Public: Content {
        let id: UUID
        let phoneNumber: String
        let name: String
        let imageURL: String?
        
        init(from user: User) {
            id = user.id!
            phoneNumber = user.phoneNumber
            name = user.name
            
            if let imageName = user.image {
                imageURL = Constants.imageRelativeURL(with: imageName)
            } else {
                imageURL = nil
            }
        }
    }
    
    struct UserInfoRequest: Content {
        let name: String
        
        init(from user: User) {
            self.name = user.name
        }
    }
    
    struct ContactsRequest: Content {
        let phones: [String]
        
        public init(phones: [String]) {
            self.phones = phones
        }
    }
    
}

extension User: ModelAuthenticatable {
    static let usernameKey: KeyPath<User, Field<String>> = \User.$phoneNumber
    static let passwordHashKey: KeyPath<User, Field<String>> = \User.$password
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
    }
}
