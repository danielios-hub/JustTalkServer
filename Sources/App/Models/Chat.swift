//
//  Chat.swift
//  
//
//  Created by Daniel Gallego Peralta on 25/12/21.
//

import Vapor
import Fluent

extension FieldKey {
    static var name: Self { "name" }
    static var imageURL: Self { "imageURL"}
    static var createdAt: Self { "createdAt" }
}

final class Chat: Model, Content {
    static let schema: String = "chat"
    
    @ID
    var id: UUID?
    
    @Field(key: .name)
    var name: String
    
    @Field(key: .imageURL)
    var imageURL: String
    
    @Field(key: .createdAt)
    var createdAt: Date
    
    @Siblings(through: ChatUserPivot.self, from: \.$chat, to: \.$user)
    var participants: [User]
    
    @Children(for: \.$chat)
    var messages: [Message]
    
    init() {}
    
    init(id: UUID? = nil, name: String, imageURL: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}

extension Chat {
    
    struct Output: Content {
        var chats: [Public]
    }
    
    struct Public: Content {
        let id: UUID
        let name: String
        let imageURL: String
        let createdAt: Date
        let participants: [User.Public]
        let lastMessage: String

        init(from chat: Chat) {
            id = chat.id!
            name = chat.name
            imageURL = chat.imageURL
            createdAt = chat.createdAt
            participants = chat.participants.map(User.Public.init)
            lastMessage = chat.messages.last?.text ?? ""
        }
    }
}
