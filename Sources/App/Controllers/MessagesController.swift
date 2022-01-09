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
    
    //MARK: - Helpers
    
    private func createResponse(messages: [Message]?) -> GenericResponse<Message.OutputList> {
        let responseObject = Message.OutputList(messages: messages ?? [])
        return GenericResponse(data: responseObject)
    }
}

struct GetMessagesInput: Content {
    var chatID: UUID
}
