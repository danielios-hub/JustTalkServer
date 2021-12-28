//
//  ChatsController.swift
//  
//
//  Created by Daniel Gallego Peralta on 25/12/21.
//

import Vapor
import Fluent

class ChatsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let chatsRoute = routes.grouped("api", "chatTest")
        
        chatsRoute.get(use: getAll)
        chatsRoute.post(use: createChat)
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = Phone.guardMiddleware()
        
        let tokenRoute = routes.grouped("api", "chat")
        let tokenAuthGroup = tokenRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware
        )
        
        tokenAuthGroup.get(use: getChatsWithUser)
    }
    
    func getAll(_ req: Request) async throws -> [Chat] {
        let chats = try await Chat.query(on: req.db).with(\.$participants).all()
        
        return chats
    }
    
    func createChat(_ req: Request) async throws -> Chat {
        let input = try req.content.decode(CreateChatInput.self)
        
        let userOne = try await Phone.find(input.userID, on: req.db)!
        let userTwo = try await Phone.find(input.userID2, on: req.db)!
        
        
        let chat = Chat(name: "Some chat name", imageURL: "", createdAt: Date())
        try await chat.save(on: req.db)
        
    
        try await chat.$participants.attach(userOne, on: req.db)
        try await chat.$participants.attach(userTwo, on: req.db)
        
        return chat
    }
    
    func getChatsWithUser(_ req: Request) async throws -> GenericResponse<Chat.Output> {
        let phone = try req.auth.require(Phone.self)

        let phoneModel = try await Phone
            .query(on: req.db)
            .filter(\.$id == phone.id!)
            .with(\.$chats)
            .first()

        return createResponse(chats: phoneModel?.chats)
    }
    
    //MARK: - Helpers
    
    private func createResponse(chats: [Chat]?) -> GenericResponse<Chat.Output> {
        let responseObject = Chat.Output(chats: chats ?? [])
        return GenericResponse(data: responseObject)
    }
}

struct CreateChatInput: Content {
    var userID: UUID
    var userID2: UUID
}