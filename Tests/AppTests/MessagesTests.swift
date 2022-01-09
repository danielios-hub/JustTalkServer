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
        let (userOne, _, chat) = try makeSetup()
        try assertResult(messages: [], chat: chat, user: userOne)
    }
    
    func test_getMessages_withOneMessage_returnMessage() throws {
        let (userOne, _, chat) = try makeSetup()
        let message = try Message.make(text: "some text", chat: chat, user: userOne, on: app.db)
        try assertResult(messages: [message], chat: chat, user: userOne)
    }
    
    func test_getMessages_withMultipleMessages_returnMessages() throws {
        let (userOne, userTwo, chat) = try makeSetup()
        let message = try Message.make(text: "some text", chat: chat, user: userOne, on: app.db)
        let anotherMessage = try Message.make(text: "some another text", chat: chat, user: userTwo, on: app.db)
        try assertResult(messages: [message, anotherMessage], chat: chat, user: userOne)
    }
    
    func test_sendMessage_withNoUser_shouldFail() throws {
        let (_, _, chat) = try makeSetup()
        let input = SendMessageInput(chatID: chat.id!, text: "some new message")
        
        try app.test(.POST, messageSendURI(), beforeRequest: { req in
            try req.content.encode(input)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
    
    func test_sendMessage_returnMessageWithID() throws {
        let (userOne, _, chat) = try makeSetup()
        let tokenOne = try Token.create(user: userOne, on: app.db)
        let input = SendMessageInput(chatID: chat.id!, text: "some new message")
        
        try app.test(.POST, messageSendURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: tokenOne.value)
            try req.content.encode(input)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let responseData = try response.content.decode(GenericResponse<Message>.self)
            XCTAssertEqual(responseData.status, .ok)
            XCTAssertEqual(responseData.data.text, input.text)
            XCTAssertNotNil(responseData.data.id)
        })
    }
    
    private func assertResult(messages: [Message], chat: Chat, user: User) throws {
        let tokenOne = try Token.create(user: user, on: app.db)
        let postModel = GetMessagesInput(chatID: chat.id!)
        
        try app.test(.POST, messageURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: tokenOne.value)
            try req.content.encode(postModel)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let messages = try response.content.decode(GenericResponse<Message.OutputList>.self).data.messages
            XCTAssertEqual(messages, messages)
        })
    }
    
    
    //MARK: - Helpers
    
    private func makeSetup() throws -> (User, User, Chat) {
        let (userOne, userTwo) = try makeUsers(on: app.db)
        let chat = try makeChat(with: "Some chat name", participants: [userOne, userTwo], on: app.db)
        return (userOne, userTwo, chat)
    }
    
    private func messageURI() -> String {
        return "api/message"
    }
    
    private func messageSendURI() -> String {
        return "api/message/send"
    }
    
}
