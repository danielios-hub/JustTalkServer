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
    
    //MARK: - Helpers
    
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

}
