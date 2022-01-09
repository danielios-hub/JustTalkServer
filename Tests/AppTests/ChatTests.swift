//
//  ChatTests.swift
//  
//
//  Created by Daniel Gallego Peralta on 26/12/21.
//

@testable import App
import XCTVapor

class ChatTests: XCTestCase {

    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func test_chat_withNoChats_returnEmptyList() throws {
        try app.test(.GET, getChatTestURI(), afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let chats = try response.content.decode([Chat].self)
            XCTAssert(chats.isEmpty)
        })
    }
    
    func test_withOnechat_twoParticipants_returnChatWithParticipants() throws {
        let (phoneOne, phoneTwo) = try makeUsers(on: app.db)
        let chatName = "Some chat name"
        let chat = try makeChat(with: chatName, participants: [phoneOne, phoneTwo], on: app.db)
        
        try app.test(.GET, getChatTestURI(), afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let chats = try response.content.decode([Chat].self)
            XCTAssertFalse(chats.isEmpty)
            
            let receivedChat = chats.first!
            XCTAssertEqual(receivedChat.id, chat.id)
            XCTAssertEqual(receivedChat.name, chatName)
        })
    }
    
    func test_getChat_fromUser_withOneChat_shouldReturnChat() throws {
        let (phoneOne, phoneTwo) = try makeUsers(on: app.db)
        let tokenOne = try Token.create(user: phoneOne, on: app.db)

        let chat = try makeChat(participants: [phoneOne, phoneTwo], on: app.db)
        try assertThatComplete(withChatIds: [chat.id!], token: tokenOne)
    }
    
    func test_getChat_fromUser_withOneChatFromAnotherUser_shouldNotReturnChat() throws {
        let (phoneOne, phoneTwo) = try makeUsers(on: app.db)
        let tokenOne = try Token.create(user: phoneOne, on: app.db)
        
        _ = try makeChat(participants: [phoneTwo], on: app.db)
        try assertThatComplete(withChatIds: [], token: tokenOne)
    }
    
    func assertThatComplete(withChatIds expectedIds: [UUID], token: Token) throws {
        try app.test(
            .POST,
            getChatURI(),
            beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token.value)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .ok)
                
                let baseResponse = try response.content.decode(GenericResponse<Chat.Output>.self)
                let data = baseResponse.data
                let chats = data.chats
                
                XCTAssertEqual(chats.count, expectedIds.count)
                for id in expectedIds {
                    XCTAssertNotNil(chats.filter { $0.id == id })
                }
                
            }
        )
    }
    
    //MARK: - Helpers
    
    func getChatURI() -> String {
        return "api/chat"
    }
    
    func getChatTestURI() -> String {
        return "api/chatTest"
    }
}
