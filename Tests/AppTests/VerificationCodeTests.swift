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
        let validPhone = anyvalidPhone()
        let validCode = anyValidVerificationCode()
        let requestPhone = PhoneRequest(number: validPhone)
        let requestCode = VerifyCodeRequest(phone: validPhone, code: validCode)
        try assertThatCompleteWith(requestPhone: requestPhone, requestCode: requestCode, isValid: true)
    }
    
    func test_verifyCode_withInvalidCodeafterVerifyPhone_shouldReturnSuccessullyWithInvalidCode() throws {
        let validPhone = anyvalidPhone()
        let invalidCode = anyInvalidVerificationCode()
        let requestPhone = PhoneRequest(number: validPhone)
        let requestCode = VerifyCodeRequest(phone: validPhone, code: invalidCode)
        try assertThatCompleteWith(requestPhone: requestPhone, requestCode: requestCode, isValid: false)
    }
    
    func test_verifyCode_withNoExistingPhoneAndValidCode_shouldReturnSuccessullyWithInvalidCode() throws {
        let invalidPhone = anyInvalidPhone()
        let validCode = anyValidVerificationCode()
        let requestPhone = PhoneRequest(number: invalidPhone)
        let requestCode = VerifyCodeRequest(phone: invalidPhone, code: validCode)
        try assertThatCompleteWith(requestPhone: requestPhone, requestCode: requestCode, isValid: false)
    }
    
    func test_verifyCode_withNoExistingPhoneAndInvalidCode_shouldReturnSuccessullyWithInvalidCode() throws {
        let invalidPhone = anyInvalidPhone()
        let invalidCode = anyInvalidVerificationCode()
        let requestPhone = PhoneRequest(number: invalidPhone)
        let requestCode = VerifyCodeRequest(phone: invalidPhone, code: invalidCode)
        try assertThatCompleteWith(requestPhone: requestPhone, requestCode: requestCode, isValid: false)
    }
    
    func assertThatCompleteWith(requestPhone: PhoneRequest, requestCode: VerifyCodeRequest, isValid: Bool, file: StaticString = #file, line: UInt = #line) throws {
        
        try app.test(.POST, getPhoneURI(), beforeRequest: { req in
            try req.content.encode(requestPhone)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok, file: file, line: line)
            
            try app.test(.POST, getVerifyCodeURI(), beforeRequest: { req in
                try req.content.encode(requestCode)
            }, afterResponse: { response in
                XCTAssertEqual(response.status, .ok, file: file, line: line)
                let responseObject = try response.content.decode(GenericResponse<VerifyCodeResponse>.self)
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
