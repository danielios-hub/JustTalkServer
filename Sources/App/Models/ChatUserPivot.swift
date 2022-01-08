//
//  ChatParticipantsPivot.swift
//  
//
//  Created by Daniel Gallego Peralta on 25/12/21.
//

import Fluent
import Foundation

extension FieldKey {
    static var chatID: Self { "chatID"}
}

final class ChatUserPivot: Model {
    static let schema = "chat-user-pivot"
    @ID
    var id: UUID?
    
    @Parent(key: .chatID)
    var chat: Chat
    
    @Parent(key: .userID)
    var user: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        chat: Chat,
        user: User
    ) throws {
        self.id = id
        self.$chat.id = try chat.requireID()
        self.$user.id = try user.requireID()
    }
}
