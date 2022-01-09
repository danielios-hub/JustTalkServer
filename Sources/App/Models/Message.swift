//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 8/1/22.
//

import Vapor
import Fluent

extension FieldKey {
    static var text: Self { "text " }
    static var date: Self { "date" }
}

final class Message: Model, Content {
    
    static let schema = "message"
    
    @ID
    var id: UUID?
    
    @Parent(key: .chatID)
    var chat: Chat
    
    @Parent(key: .userID)
    var user: User
    
    @Field(key: .text)
    var text: String
    
    @Field(key: .date)
    var date: Date
    
    init() {}
    
    init(
        id: UUID? = nil,
        chat: Chat,
        user: User,
        text: String,
        date: Date
    ) throws {
        self.id = id
        self.$chat.id = try chat.requireID()
        self.$user.id = try user.requireID()
        self.text = text
        self.date = date
    }
}

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
        lhs.text == rhs.text
    }
}

extension Message {
    struct OutputList: Content {
        let messages: [Message]
    }
}
