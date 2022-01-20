//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

@testable import App
import Fluent
import Foundation

extension User {
    static func create(number: String = "123456", password: String = "1111", name: String = "a name", on db: Database) throws -> User {
        let user =  User(phoneNumber: number, password: password, name: name)
        try user.save(on: db).wait()
        return user
    }
}

extension Token {
    static func create(user: User, on db: Database) throws -> Token {
        let token = try Token.generate(for: user)
        try token.save(on: db).wait()
        return token
    }
}

extension Chat {
    static func create(name: String, imageURL: String = "", users: [User], on db: Database) throws -> Chat {
        let chat = Chat(name: name, imageURL: imageURL, createdAt: Date())
        try chat.save(on: db).wait()
        
        if !users.isEmpty {
            try chat.$participants.attach(users, on: db).wait()
        }
        
        return chat
    }
}

extension Message {
    static func make(text: String = "", date: Date = Date(), chat: Chat, user: User, on db: Database) throws -> Message {
        let message = try Message(chat: chat, user: user, text: text, date: date)
        try message.save(on: db).wait()
        return message
    }
}
