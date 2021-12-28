//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

@testable import App
import Fluent
import Foundation

extension Phone {
    static func create(number: String = "123456", password: String = "1111", on db: Database) throws -> Phone {
        let phone =  Phone(number: number, password: password)
        try phone.save(on: db).wait()
        return phone
    }
}

extension Token {
    static func create(phone: Phone, on db: Database) throws -> Token {
        let token = try Token.generate(for: phone)
        try token.save(on: db).wait()
        return token
    }
}

extension Chat {
    static func create(name: String, imageURL: String = "", phones: [Phone], on db: Database) throws -> Chat {
        let chat = Chat(name: name, imageURL: imageURL, createdAt: Date())
        try chat.save(on: db).wait()
        
        if !phones.isEmpty {
            try chat.$participants.attach(phones, on: db).wait()
        }
        
        return chat
    }
}
