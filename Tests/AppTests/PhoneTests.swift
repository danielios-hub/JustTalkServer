//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

@testable import App
import XCTVapor

final class PhoneTests: XCTestCase {
    
    var app: Application!
    
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func test_phoneValidate_withInvalidPhone_shouldReturnSuccessWithInvalidPhone() throws {
        let invalidPhone = anyInvalidPhone()
        let request = PhoneRequest(number: invalidPhone)
        try assertThatCompleteWith(request: request, isValid: false, number: invalidPhone)
    }
    
    func test_phoneValidate_withNonExistingPhone_shouldReturnSuccessWithValidPhone() throws {
        let validPhone = anyvalidPhone()
        let request = PhoneRequest(number: validPhone)
        try assertThatCompleteWith(request: request, isValid: true, number: validPhone)
    }
    
    func test_phoneValidate_withExistingPhone_shouldReturnSuccessWithValidPhone() throws {
        let validPhone = anyvalidPhone()
        _ = try Phone.create(number: validPhone, on: app.db)
        let request = PhoneRequest(number: validPhone)
        
        try assertThatCompleteWith(request: request, isValid: true, number: validPhone)
    }
    
    func assertThatCompleteWith(request: PhoneRequest, isValid: Bool, number: String, file: StaticString = #file, line: UInt = #line) throws {
        try app.test(.POST, getPhoneURI(), beforeRequest: { req in
            try req.content.encode(request)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok, file: file, line: line)
            let response = try response.content.decode(GenericResponse<PhoneResponse>.self)
            let data = response.data
            XCTAssertEqual(data.phoneNumber, number, file: file, line: line)
            XCTAssertEqual(data.isNumberValid, isValid, file: file, line: line)
        })
    }
    
    //MARK: - Helper
                     
    func getPhoneURI() -> String {
        return "api/phones/validate"
    }
    
    func anyInvalidPhone() -> String {
        return "12sd33f"
    }
    
    func anyvalidPhone() -> String {
        return "1234567"
    }
    
}
