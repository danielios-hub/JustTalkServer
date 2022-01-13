//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 13/1/22.
//

import Vapor

class NotificationSocketsManager  {
    static var shared = NotificationSocketsManager()
    
    // FIXME: - thread safe(use property wrapper
    private var connectedUsers = [UUID: WebSocket]()
    
    private init() {}
    
    private func flush() {
        connectedUsers.filter { $0.value.isClosed }
        .map(\.key)
        .forEach(remove)
    }
    
    func insert(id: UUID, on ws: WebSocket) {
        connectedUsers[id] = ws
    }
    
    func sendMessage(_ message: Message, to userIDs: [UUID]) {
        flush()
        sendMessages([message], to: userIDs)
    }
    
    func sendMessages(_ messages: [Message], to userIDs: [UUID]) {
        let message = SocketMessage(chatMessages: messages)
        
        for userID in userIDs {
            if let channel = connectedUsers[userID] {
                channel.send(message)
            }
        }
    }
    
    func remove(id: UUID) {
        connectedUsers[id] = nil
    }
}
