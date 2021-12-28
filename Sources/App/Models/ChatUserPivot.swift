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
    
    @Parent(key: .phoneID)
    var phone: Phone
    
    init() {}
    
    init(
        id: UUID? = nil,
        chat: Chat,
        phone: Phone
    ) throws {
        self.id = id
        self.$chat.id = try chat.requireID()
        self.$phone.id = try phone.requireID()
    }
}
