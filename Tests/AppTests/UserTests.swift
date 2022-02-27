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
    
    func test_editUserImage_withNoToken_shouldReturnError() throws {
        let input = EditImageRequest.init(data: Data("any data".utf8))
        
        try app.test(.POST, imagUserUploadURI(), beforeRequest: { req in
            try req.content.encode(input)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
    
    //TODO: - Image Validation
//    func test_editUserImage_withInvalidData_shouldReturnFailure() throws {
//        let (_, token) = try makeUserToken(on: app.db)
//        let input = ImageUploadData.init(data: Data("any data".utf8))
//
//        try assertThatCompleteWith(request: input, token: token, expectedStatusResponse: .failure, expectedObjectNil: true)
//    }
    
    func test_editUserImage_withValidDataAndUserWithNoImage_shouldReturnUpdatedUser() throws {
        cleanImagesDirectory()
        let (_, token) = try makeUserToken(on: app.db)
        let input = try makeValidImageRequest()
        
        try assertThatCompleteWith(request: input, token: token, expectedStatusResponse: .ok, expectedObjectNil: false)
    }
    
    func test_editUserImage_withValidDataAndUserWithExistingImage_shouldReturnUpdatedUser() throws {
        cleanImagesDirectory()
        let (user, token) = try makeUserToken(on: app.db)
        user.image = "someImageName.jpg"
        try user.save(on: app.db).wait()
        let input = try makeValidImageRequest()
        
        try assertThatCompleteWith(request: input, token: token, expectedStatusResponse: .ok, expectedObjectNil: false)
    }
    
    func test_getUsersByPhone_withNoPhones_returnEmptyList() throws {
        let (_, token) = try makeUserToken(on: app.db)
        let input = User.ContactsRequest(phones: [])
        
        try assertThatCompleteWith(request: input, token: token, with: [])
    }
    
    func test_getUsersByPhone_withPhonesButNoMatches_returnEmptyList() throws {
        let ((_, token), _) = try makeCommonSetup(on: app)
        let input = User.ContactsRequest(phones: [anyvalidPhone()])
        
        try assertThatCompleteWith(request: input, token: token, with: [])
    }
    
    func test_getUsersByPhone_withPhonesAndOneMatch_returnListWithMatchingContact() throws {
        let ((_, token), anotherUser) = try makeCommonSetup(on: app)
        let matchingPhones = [anotherUser.phoneNumber]
        let input = User.ContactsRequest(phones: matchingPhones)
        
        try assertThatCompleteWith(request: input, token: token, with: matchingPhones)
    }
    
    func test_getUsersByPhone_withPhonesAndMultipleMatches_returnListWithMatchingContacts() throws {
        let ((_, token), _) = try makeCommonSetup(on: app)
        let allPhones = ["606646740", "606646741", "606646742", "606646743", "606646744"]
        let matchingPhones = ["606646741", "606646742", "606646744"]
        try allPhones.forEach { _ = try makeUser(number: $0, on: app.db) }
        let input = User.ContactsRequest(phones: matchingPhones)
        
        try assertThatCompleteWith(request: input, token: token, with: matchingPhones)
    }
    
    //MARK: - Helpers
    
    private func assertThatCompleteWith(request: User.Input, isValid: Bool, number: String, file: StaticString = #file, line: UInt = #line) throws {
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
    
    private func assertThatCompleteWith(request: User.ContactsRequest, token: Token, with expectedPhones: [String], file: StaticString = #file, line: UInt = #line) throws {
        try app.test(.POST, contactsURI(), beforeRequest: { req in
            try req.content.encode(request)
            req.headers.bearerAuthorization = .init(token: token.value)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let data = try response.content.decode(GenericResponse<[User.Public]>.self).data
            XCTAssertEqual(data.count, expectedPhones.count)
            
            for expectedPhone in expectedPhones {
                XCTAssert(data.contains { $0.phoneNumber == expectedPhone }, "Expected \(expectedPhone) to be in \(data)")
            }
        })
    }
    
    private func assertThatCompleteWith(
        request: EditImageRequest,
        token: Token?,
        expectedStatusResponse: StatusResponse,
        expectedObjectNil: Bool) throws {
        try app.test(.POST, imagUserUploadURI(), beforeRequest: { req in
            try req.content.encode(request)
            if let token = token {
                req.headers.bearerAuthorization = .init(token: token.value)
            }
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let baseResponse = try response.content.decode(GenericResponse<OptionalObject<User.Public>>.self)
            XCTAssertEqual(baseResponse.status, expectedStatusResponse)
            XCTAssertEqual(baseResponse.data.object == nil, expectedObjectNil)
            XCTAssertEqual(baseResponse.data.object?.imageURL == nil, expectedObjectNil)
            cleanImagesDirectory()
        })
    }
    
    private func makeValidImageRequest() throws -> EditImageRequest {
        let url = getExampleImageURL()
        let imageData = try Data(contentsOf: url)
        return EditImageRequest.init(data: imageData)
    }
    
    private func cleanImagesDirectory() {
        let folderImagesPath =  Constants.imagesFolderURL(with: app.directory.workingDirectory)
        try? FileManager.default.removeItem(atPath: folderImagesPath)
    }
    
    private func userURI() -> String {
        return "api/user"
    }
    
    private func contactsURI() -> String {
        return "api/user/contacts"
    }
    
    private func imagUserUploadURI() -> String {
        return "api/user/profilePicture"
    }
    
    private func getExampleImageURL() -> URL {
        return URL(string: "https://www.cleverfiles.com/howto/wp-content/uploads/2018/03/minion.jpg")!
    }

}
