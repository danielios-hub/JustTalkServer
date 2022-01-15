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
        
        let connectedMessage = SocketConnected(successfull: true)
        sendEvent(.connected(connectedMessage), to: [id])
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
    
    func sendEvent(_ event: WebSocketEvent, to userIDs: [UUID]) {
        flush()
        
        switch event {
        case .connected(let socketConnected):
            for userID in userIDs {
                if let channel = connectedUsers[userID] {
                    channel.send(socketConnected)
                }
            }
        case .message(let socketMessage):
            for userID in userIDs {
                if let channel = connectedUsers[userID] {
                    channel.send(socketMessage)
                }
            }
        }
    }
    
    func remove(id: UUID) {
        connectedUsers[id] = nil
    }
}

enum WebSocketEvent {
    case connected(SocketConnected)
    case message(SocketMessage)
}
