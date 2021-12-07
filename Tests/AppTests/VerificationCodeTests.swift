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
        let requestPhone = PhoneRequest(number: phone)
        let requestCode = VerificationCode.Input(phone: phone, code: code)
        try assertThatCompleteWith(requestPhone: requestPhone, requestCode: requestCode, isValid: isValid)
    }
    
    func assertThatCompleteWith(requestPhone: PhoneRequest, requestCode: VerificationCode.Input, isValid: Bool, file: StaticString = #file, line: UInt = #line) throws {
        
        try app.test(.POST, getPhoneURI(), beforeRequest: { req in
            try req.content.encode(requestPhone)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok, file: file, line: line)
            
            try app.test(.POST, getVerifyCodeURI(), beforeRequest: { req in
                try req.content.encode(requestCode)
            }, afterResponse: { response in
                XCTAssertEqual(response.status, .ok, file: file, line: line)
                let responseObject = try response.content.decode(GenericResponse<VerificationCode.Output>.self)
                let data = responseObject.data
                XCTAssertEqual(data.isCodeCorrect, isValid, file: file, line: line)
                XCTAssertEqual(data.code, requestCode.code, file: file, line: line)
            })
        })
    }
    
    
    //MARK: - Helpers
    
    func getVerifyCodeURI() -> String {
        return "api/code/validate"
    }
    
    func anyInvalidVerificationCode() -> String {
        return "1234578"
    }
    
}
