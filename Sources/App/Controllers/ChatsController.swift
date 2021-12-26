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
        let chatsRoute = routes.grouped("api", "chat")
        
        chatsRoute.get(use: getAll)
    }
    
    func getAll(_ req: Request) async throws -> [Chat] {
        let chats = try await Chat.query(on: req.db).all()
        
        return chats
    }
}
