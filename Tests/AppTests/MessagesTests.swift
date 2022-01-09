//
//  MessagesTests.swift
//  
//
//  Created by Daniel Gallego Peralta on 8/1/22.
//

@testable import App
import XCTVapor

final class MessagesTests: XCTestCase {
    
    var app: Application!
    
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func test_getMessages_inChatWithNoMessages_returnEmptyMessage() throws {
        let (userOne, userTwo) = try makeUsers(on: app.db)
        let chatName = "Some chat name"
        let tokenOne = try Token.create(user: userOne, on: app.db)
        let chat = try makeChat(with: chatName, participants: [userOne, userTwo], on: app.db)
        let postModel = GetMessagesInput(chatID: chat.id!)
        
        try app.test(.POST, messageURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: tokenOne.value)
            try req.content.encode(postModel)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let messages = try response.content.decode(GenericResponse<Message.OutputList>.self).data.messages
            XCTAssert(messages.isEmpty)
        })
    }
    
    func test_getMessages_withOneMessage_returnMessage() throws {
        let (userOne, userTwo) = try makeUsers(on: app.db)
        let chatName = "Some chat name"
        let tokenOne = try Token.create(user: userOne, on: app.db)
        let chat = try makeChat(with: chatName, participants: [userOne, userTwo], on: app.db)
        let postModel = GetMessagesInput(chatID: chat.id!)
        let message = try Message.make(text: "some text", chat: chat, user: userOne, on: app.db)
        
        try app.test(.POST, messageURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: tokenOne.value)
            try req.content.encode(postModel)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let messages = try response.content.decode(GenericResponse<Message.OutputList>.self).data.messages
            XCTAssertEqual(messages, [
                message
            ])
        })
    }
    
    func test_getMessages_withMultipleMessages_returnMessages() throws {
        let (userOne, userTwo) = try makeUsers(on: app.db)
        let chatName = "Some chat name"
        let tokenOne = try Token.create(user: userOne, on: app.db)
        let chat = try makeChat(with: chatName, participants: [userOne, userTwo], on: app.db)
        let postModel = GetMessagesInput(chatID: chat.id!)
        let message = try Message.make(text: "some text", chat: chat, user: userOne, on: app.db)
        let anotherMessage = try Message.make(text: "some another text", chat: chat, user: userTwo, on: app.db)
        
        try app.test(.POST, messageURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: tokenOne.value)
            try req.content.encode(postModel)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let messages = try response.content.decode(GenericResponse<Message.OutputList>.self).data.messages
            XCTAssertEqual(messages, [
                message,
                anotherMessage
            ])
        })
    }
    
    
    //MARK: - Helpers
    
    private func messageURI() -> String {
        return "api/message"
    }
    
}
