//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 8/1/22.
//

import Vapor

class MessagesController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let messageTestRoute = routes.grouped("api", "messageTest")
        messageTestRoute.get(use: getAll)
        
        
        let messagesRoute = routes.grouped("api", "message")
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        
        let tokenAuthGroup = messagesRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware
        )
        
        tokenAuthGroup.post(use: getMessagesInChat)
        
        let sendRoute = tokenAuthGroup.grouped("send")
        sendRoute.post(use: sendMessage)
    }
    
    //MARK: - Test
    
    func getAll(_ req: Request) async throws -> [Message] {
        let messages = try await Message.query(on: req.db).all()
        return messages
    }
    
    //MARK: - Prod
    
    func getMessagesInChat(_ req: Request) async throws -> GenericResponse<Message.OutputList> {
        let input = try req.content.decode(GetMessagesInput.self)
        let chat = try await Chat.find(input.chatID, on: req.db)
        let messages = try await chat?.$messages.get(reload: true, on: req.db)
        return createResponse(messages: messages)
    }
    
    func sendMessage(_ req: Request) async throws -> GenericResponse<Message> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(SendMessageInput.self)
        let chat = try await Chat.find(input.chatID, on: req.db)
        
        guard let chat = chat else {
            return createFailureResponse()
        }
        
        let message = try Message(chat: chat, user: user, text: input.text, date: Date())
        try await message.save(on: req.db)
        
        let participants = try await chat.$participants.get(reload: true, on: req.db)
        let participantsIDs = participants.compactMap { $0.id}
        sendNotification(message: message, to: participantsIDs)
        
        return createResponseMessage(message)
    }
    
    //MARK: - Helpers
    
    private func sendNotification(message: Message, to usersID: [UUID]) {
        NotificationSocketsManager.shared.sendMessages([message], to: usersID)
    }
    
    private func createResponse(messages: [Message]?) -> GenericResponse<Message.OutputList> {
        let responseObject = Message.OutputList(messages: messages ?? [])
        return GenericResponse(data: responseObject)
    }
    
    private func createResponseMessage(_ message: Message) -> GenericResponse<Message> {
        return GenericResponse(data: message)
    }
    
    private func createFailureResponse() -> GenericResponse<Message> {
        return GenericResponse<Message>.failure(data: Message())
    }
}

struct GetMessagesInput: Content {
    var chatID: UUID
}

struct SendMessageInput: Content {
    var chatID: UUID
    var text: String
}
