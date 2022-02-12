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

        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        
        let chatRoute = routes.grouped("api", "chat")
        let tokenAuthGroup = chatRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware
        )
        
        tokenAuthGroup.post(use: getChatsWithUser)
        
        let createdChatRoute = tokenAuthGroup.grouped("create")
        createdChatRoute.post(use: createChat)
    }
    
    func getAll(_ req: Request) async throws -> [Chat] {
        let chats = try await Chat.query(on: req.db).with(\.$participants).all()
        
        return chats
    }
    
    func createChat(_ req: Request) async throws -> GenericResponse<Chat.OptionalChat> {
        do {
            let user = try req.auth.require(User.self)
            let input = try req.content.decode(CreateChatRequest.self)
            
            guard let withUser = try await User.find(input.userID, on: req.db) else {
                return createFailureResponse()
            }
            
            if let existingChat = try await searchExistingChat(user: user, withUser: withUser, on: req) {
                _ = try await existingChat.$messages.get(on: req.db)
                return createResponse(existingChat, ownUserID: try user.requireID())
            }
                
            let chat = try await createNewChat(user: user, withUser: withUser, on: req)
            return createResponse(chat, ownUserID: try user.requireID())
        } catch {
            return createFailureResponse()
        }
    }
    
    func getChatsWithUser(_ req: Request) async throws -> GenericResponse<Chat.Output> {
        let user = try req.auth.require(User.self)

        let phoneModel = try await User
            .query(on: req.db)
            .filter(\.$id == user.id!)
            .with(\.$chats) {
                $0.with(\.$participants)
                $0.with(\.$messages)
            }
            .first()

        return createResponse(chats: phoneModel?.chats, ownUserID: try user.requireID())
    }
    
    //MARK: - Helpers
    
    private func createResponse(chats: [Chat]?, ownUserID: UUID) -> GenericResponse<Chat.Output> {
        let chatsOutput = chats?.map { Chat.Public(from: $0, ownUserID: ownUserID) } ?? []
        let responseObject = Chat.Output(chats: chatsOutput)
        return GenericResponse(data: responseObject)
    }
    
    private func createResponse(_ chat: Chat, ownUserID: UUID) -> GenericResponse<Chat.OptionalChat> {
        let publicChat = Chat.OptionalChat(chat: Chat.Public(from: chat, ownUserID: ownUserID))
        return GenericResponse(data: publicChat)
    }
    
    private func createFailureResponse() -> GenericResponse<Chat.OptionalChat> {
        return GenericResponse<Chat.OptionalChat>.failure(data: Chat.OptionalChat(chat: nil))
    }
    
    private func searchExistingChat(user: User, withUser: User, on req: Request) async throws -> Chat? {
        let currentChats = try await user.$chats.get(on: req.db)
        for chat in currentChats {
            _ = try await chat.$participants.get(on: req.db)
        }
        
        return currentChats.filter { chat in
            let participantsID = chat.participants.map { $0.id! }
            return participantsID.contains { $0 == withUser.id! }
        }.first
    }
    
    private func createNewChat(user: User, withUser: User, on req: Request, loadParticipants: Bool = true, loadMessages: Bool = true) async throws -> Chat {
        let chat = Chat(name: "Some chat name", imageURL: "", createdAt: Date())
        try await chat.save(on: req.db)
        
    
        try await chat.$participants.attach(user, on: req.db)
        try await chat.$participants.attach(withUser, on: req.db)
        
        if loadParticipants {
            _ = try await chat.$participants.get(on: req.db)
        }
        
        if loadMessages {
            _ = try await chat.$messages.get(on: req.db)
        }
        
        return chat
    }
}

struct CreateChatRequest: Content {
    var userID: UUID
}
