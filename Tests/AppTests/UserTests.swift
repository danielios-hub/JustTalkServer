//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    
    var app: Application!
    
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func test_phoneValidate_withInvalidPhone_shouldReturnSuccessWithInvalidPhone() throws {
        let invalidPhone = anyInvalidPhone()
        let request = User.Input(number: invalidPhone)
        try assertThatCompleteWith(request: request, isValid: false, number: invalidPhone)
    }
    
    func test_phoneValidate_withNonExistingPhone_shouldReturnSuccessWithValidPhone() throws {
        let validPhone = anyvalidPhone()
        let request = User.Input(number: validPhone)
        try assertThatCompleteWith(request: request, isValid: true, number: validPhone)
    }
    
    func test_phoneValidate_withExistingPhone_shouldReturnSuccessWithValidPhone() throws {
        let validPhone = anyvalidPhone()
        _ = try User.create(number: validPhone, on: app.db)
        let request = User.Input(number: validPhone)
        
        try assertThatCompleteWith(request: request, isValid: true, number: validPhone)
    }
    
    func test_editInfo_withUserEmptyName_shouldUpdateName() throws {
        let name = "a username"
        let (user, token) = try makeUserToken(on: app.db)
    
        user.name = name
        let input = User.UserInfoRequest(from: user)
        try app.test(.POST, userURI(), beforeRequest: { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { req in
            XCTAssertEqual(req.status, .ok)
            
            let user = try req.content.decode(GenericResponse<User.Public>.self).data
            XCTAssertEqual(user.name, name)
        })
    }
    
    func test_getUsersByPhone_withNoPhones_returnEmptyList() throws {
        let (_, token) = try makeUserToken(on: app.db)
        let input = User.ContactsRequest(phones: [])
        
        try app.test(.POST, contactsURI(), beforeRequest: { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let data = try response.content.decode(GenericResponse<[User.Public]>.self).data
            XCTAssert(data.isEmpty)
        })
        
    }
    
    func test_getUsersByPhone_withPhonesButNoMatches_returnEmptyList() throws {
        let ((_, token), _) = try makeCommonSetup(on: app)
        let input = User.ContactsRequest(phones: [anyvalidPhone()])
        
        try app.test(.POST, contactsURI(), beforeRequest: { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let data = try response.content.decode(GenericResponse<[User.Public]>.self).data
            XCTAssert(data.isEmpty)
        })
    }
    
    func test_getUsersByPhone_withPhonesAndOneMatch_returnListWithMatchingContact() throws {
        let ((_, token), anotherUser) = try makeCommonSetup(on: app)
        let input = User.ContactsRequest(phones: [anotherUser.phoneNumber])
        
        try app.test(.POST, contactsURI(), beforeRequest: { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let data = try response.content.decode(GenericResponse<[User.Public]>.self).data
            XCTAssertEqual(data.count, 1)
        })
    }
    
    func test_getUsersByPhone_withPhonesAndMultipleMatches_returnListWithMatchingContacts() throws {
        let ((_, token), _) = try makeCommonSetup(on: app)
        
        let allPhones = ["606646740", "606646741", "606646742", "606646743", "606646744"]
        let matchingPhones = ["606646741", "606646742", "606646744"]
        
        try allPhones.forEach { _ = try makeUser(number: $0, on: app.db) }
        let input = User.ContactsRequest(phones: matchingPhones)
        
        try app.test(.POST, contactsURI(), beforeRequest: { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let data = try response.content.decode(GenericResponse<[User.Public]>.self).data
            XCTAssertEqual(data.count, matchingPhones.count)
        })
    }
    
    //MARK: - Helpers
    
    private func makeCommonSetup(on app: Application) throws -> ((User, Token), User) {
        let (user, anotherUser) = try makeUsers(on: app.db)
        let token = try Token.create(user: user, on: app.db)
        return ((user, token), anotherUser)
    }
    
    func assertThatCompleteWith(request: User.Input, isValid: Bool, number: String, file: StaticString = #file, line: UInt = #line) throws {
        try app.test(.POST, getPhoneURI(), beforeRequest: { req in
            try req.content.encode(request)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok, file: file, line: line)
            let response = try response.content.decode(GenericResponse<User.Output>.self)
            let data = response.data
            XCTAssertEqual(data.phoneNumber, number, file: file, line: line)
            XCTAssertEqual(data.isNumberValid, isValid, file: file, line: line)
        })
    }
    
    private func userURI() -> String {
        return "api/user"
    }
    
    private func contactsURI() -> String {
        return "api/user/contacts"
    }

}
