//
//  VerificationCodeTests.swift
//  
//
//  Created by Daniel Gallego Peralta on 7/12/21.
//

@testable import App
import XCTVapor

final class VerificationCodeTests: XCTestCase {
    
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func test_verifyCode_withValidCodeafterVerifyPhone_shouldReturnSuccessully() throws {
        try assert(phone: anyvalidPhone(), code: anyValidVerificationCode(), isValid: true)
    }
    
    func test_verifyCode_withInvalidCodeafterVerifyPhone_shouldReturnSuccessullyWithInvalidCode() throws {
        try assert(phone: anyvalidPhone(), code: anyInvalidVerificationCode(), isValid: false)
    }
    
    func test_verifyCode_withNoExistingPhoneAndValidCode_shouldReturnSuccessullyWithInvalidCode() throws {
        try assert(phone: anyInvalidPhone(), code: anyValidVerificationCode(), isValid: false)
    }
    
    func test_verifyCode_withNoExistingPhoneAndInvalidCode_shouldReturnSuccessullyWithInvalidCode() throws {
        try assert(phone: anyInvalidPhone(), code: anyInvalidVerificationCode(), isValid: false)
    }
    
    func assert(phone: String, code: String, isValid: Bool, file: StaticString = #file, line: UInt = #line) throws {
        let requestPhone = Phone.Input(number: phone)
        let requestCode = VerificationCode.Input(phone: phone, code: code)
        try assertThatCompleteWith(requestPhone: requestPhone, requestCode: requestCode, isValid: isValid)
    }
    
    func assertThatCompleteWith(requestPhone: Phone.Input, requestCode: VerificationCode.Input, isValid: Bool, file: StaticString = #file, line: UInt = #line) throws {
        
        try app.test(.POST, getPhoneURI(), beforeRequest: { req in
            try req.content.encode(requestPhone)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok, file: file, line: line)
                      
            try app.test(.POST, getLoginURI(), beforeRequest: { req in
                req.headers.basicAuthorization = .init(username: requestCode.phone, password: requestCode.code)
            }, afterResponse: { response in
                XCTAssertEqual(response.status, .ok, file: file, line: line)
                let responseObject = try response.content.decode(GenericResponse<VerificationCode.Output>.self)
                let data = responseObject.data
                XCTAssertEqual(data.isCodeCorrect, isValid, file: file, line: line)
                XCTAssertEqual(data.token != nil, data.isCodeCorrect, file: file, line: line)
            })
        })
    }
    
    func test_tokenValid_withNoToken_returnNotValid() throws {
        try app.test(.GET, getTokenValidURI(), afterResponse: { response in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
    
    func test_tokenValid_withInvalidToken_returnNotValid() throws {
        try app.test(.GET, getTokenValidURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: anyInvalidToken())
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
    
    func test_tokenValid_withValidToken_returnOK() throws {
        let phone = try Phone.create(number: anyvalidPhone(), password: anyValidVerificationCode(), on: app.db)
        let token = try Token.create(phone: phone, on: app.db)
        
        try app.test(.GET, getTokenValidURI(), beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }
    
    
    //MARK: - Helpers
    
    func getVerifyCodeURI() -> String {
        return "api/code/validate"
    }
    
    func getLoginURI() -> String {
        return "api/login"
    }
    
    func getTokenValidURI() -> String {
        return "api/token/valid"
    }
    
    func anyInvalidVerificationCode() -> String {
        return "1234578"
    }
    
    func anyInvalidToken() -> String {
        return "df12Fcsdfsdf=="
    }
    
}
