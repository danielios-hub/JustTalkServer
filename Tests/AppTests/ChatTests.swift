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
        let (user, token) = try makeUserToken(on: app.db)
        let anotherUser = try makeUser(number: "606646712", password: "1111", name: "another username", on: app.db)
        let chat = try makeChat(participants: [user, anotherUser], on: app.db)
        try assertThatComplete(withChatIds: [chat.id!], expectedNames: [anotherUser.name], token: token)
    }
    
    func test_getChat_fromUser_withOneChatFromAnotherUser_shouldNotReturnChat() throws {
        let (phoneOne, phoneTwo) = try makeUsers(on: app.db)
        let tokenOne = try Token.create(user: phoneOne, on: app.db)
        
        _ = try makeChat(participants: [phoneTwo], on: app.db)
        try assertThatComplete(withChatIds: [], token: tokenOne)
    }
    
    func assertThatComplete(withChatIds expectedIds: [UUID], expectedNames: [String] = [], token: Token) throws {
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
                
                XCTAssertEqual(chats.map { $0.name }, expectedNames)
            }
        )
    }
    
    func test_createChat_withWrongUserID_shouldReturnFailure() throws {
        let ((_, token), _) = try makeCommonSetup(on: app)
        let input = CreateChatRequest(userID: UUID())
        try assertChatCreation(input: input, token: token, expectedStatusResponse: .failure, expectedChatID: nil)
    }
    
    func test_createChat_withExistingChatWithUserID_shouldReturnPreviousChat() throws {
        let ((user, token), anotherUser) = try makeCommonSetup(on: app)
        let previousChat = try makeChat(participants: [user, anotherUser], on: app.db)
        let input = CreateChatRequest(userID: try anotherUser.requireID())
        
        try assertChatCreation(input: input, token: token, expectedStatusResponse: .ok, expectedChatID: previousChat.id)
    }
    
    func test_createChat_withNotExistingUserID_shouldReturnNewChat() throws {
        let ((_, token), anotherUser) = try makeCommonSetup(on: app)
        let input = CreateChatRequest(userID: try anotherUser.requireID())
        try app.test(
            .POST,
            getCreateChatURI(),
            beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token.value)
                try req.content.encode(input)
            }, afterResponse: { response in
                XCTAssertEqual(response.status, .ok)
                let objectResponse = try response.content.decode(GenericResponse<Chat.OptionalChat>.self)
                XCTAssertEqual(objectResponse.status, .ok)
                XCTAssertNotNil(objectResponse.data.chat)
            }
        )
    }

    private func assertChatCreation(input: CreateChatRequest, token: Token, expectedStatusResponse: StatusResponse, expectedChatID: UUID?, file: StaticString = #file, line: UInt = #line) throws {
        try app.test(
            .POST,
            getCreateChatURI(),
            beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token.value)
                try req.content.encode(input)
            }, afterResponse: { response in
                XCTAssertEqual(response.status, .ok, file: file, line: line)
                let objectResponse = try response.content.decode(GenericResponse<Chat.OptionalChat>.self)
                XCTAssertEqual(objectResponse.status, expectedStatusResponse, file: file, line: line)
                XCTAssertEqual(objectResponse.data.chat?.id, expectedChatID, file: file, line: line)
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
    
    func getCreateChatURI() -> String {
        return "\(getChatURI())/create"
    }
}
