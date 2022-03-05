//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    let fileService: FileService
    
    init(fileService: FileService = FileServiceImpl.shared) {
        self.fileService = fileService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let phonesRoute = routes.grouped("api", "phones")
        
        phonesRoute.post("validate", use: validatePhone)
        phonesRoute.get(use: getAllHandler)
        
        let usersRoute = routes.grouped("api", "user")
        let tokenAuthMiddleware = Token.authenticator()
        let userMiddleware = User.guardMiddleware()
        
        let protectedRoutes = usersRoute.grouped(
            tokenAuthMiddleware,
            userMiddleware
        )
        
        protectedRoutes.post(use: editUserInfoHandler)
        protectedRoutes.grouped("profilePicture")
            .on(.POST,
                body: .collect(maxSize: "10mb"),
                use: editUserImageHandler)
        protectedRoutes.grouped("contacts").post(use: getUsersByPhone)
    }
    
    func getAllHandler(_ req: Request) async throws -> [User] {
        return try await User.query(on: req.db).all()
    }
   
    func validatePhone(_ req: Request) async throws -> GenericResponse<User.Output> {
        let request = try req.content.decode(User.Input.self)
        
        guard PhoneValidator.isValidNumber(request.number) else {
            return createResponse(isValid: false, number: request.number)
        }
        
        let phoneObject = try await User.query(on: req.db)
            .filter(\.$phoneNumber == request.number)
            .first()
        
        if phoneObject == nil {
            let newCode = CodeGenerator.generateCode()
            let hashCode = try Bcrypt.hash(newCode)
            let newPhone = User(phoneNumber: request.number, password: hashCode)
            newPhone.password = hashCode
            try await newPhone.save(on: req.db)
            let verificationCode = VerificationCode(code: newCode, userID: newPhone.id!)
            try await verificationCode.save(on: req.db)
        }
        
        return createResponse(isValid: true, number: request.number)
    }
    
    func editUserInfoHandler(_ req: Request) async throws -> GenericResponse<User.Public> {
        let input = try req.content.decode(User.UserInfoRequest.self)
        let user = try req.auth.require(User.self)
        
        user.name = input.name
        try await user.save(on: req.db)
        return createResponse(with: user)
    }
    
    func editUserImageHandler(_ req: Request) async throws -> GenericResponse<OptionalObject<User.Public>> {
        do {
            let input = try req.content.decode(EditImageRequest.self)
            let user = try req.auth.require(User.self)
            
            let imageName = try getImageName(from: user)
            let directory = req.application.directory.workingDirectory
            let folderPath = Constants.imagesFolderURL(with:  directory)
            let imagePath = Constants.imageURL(with: directory, imageName: imageName)
            try fileService.createDirectoryIfNeeded(at: folderPath)
            try await req.fileio.writeFile(.init(data: input.data), at: imagePath)
            
            user.image = imageName
            try await user.save(on: req.db)
            return createResponse(with: user)
        } catch let error {
            print(error)
            return createFailureResponse()
        }
    }
    
    func getUsersByPhone(_ req: Request) async throws -> GenericResponse<[User.Public]> {
        let input = try req.content.decode(User.ContactsRequest.self)
        let requestPhones = input.phones
        
        guard !requestPhones.isEmpty else {
            return createResponse(users: [])
        }

        let users = try await User.query(on: req.db)
            .group(.or) { group in
            for phone in requestPhones {
                group.filter(\.$phoneNumber == phone)
            }
        } .all()
    
        return createResponse(users: users)
    }
    
    //MARK: - Helpers
    
    private func createResponse(isValid: Bool, number: String) -> GenericResponse<User.Output> {
        let responseObject = User.Output(isNumberValid: isValid, phoneNumber: number)
        return GenericResponse(data: responseObject)
    }
    
    private func createResponse(users: [User]) -> GenericResponse<[User.Public]> {
        let responseObject: [User.Public] = users.map { User.Public(from: $0) }
        return GenericResponse(data: responseObject)
    }
    
    private func createResponse(with user: User) -> GenericResponse<User.Public> {
        let response = User.Public(from: user)
        return GenericResponse(data: response)
    }
    
    private func createResponse(with user: User) -> GenericResponse<OptionalObject<User.Public>> {
        let response = OptionalObject(object: User.Public(from: user))
        return GenericResponse(data: response)
    }
    
    private func createFailureResponse() -> GenericResponse<OptionalObject<User.Public>> {
        return .failure(data: OptionalObject(object: nil))
    }
    
    private func getImageName(from user: User) throws -> String {
        if let name = user.image {
            return name
        } else {
            return "\(try user.requireID())_\(UUID().uuidString).jpg"
        }
    }
}

enum PhoneError: Error {
    case noExisting
}

struct EditImageRequest: Content {
    let data: Data
}

struct OptionalObject<T: Content>: Content {
    let object: T?
}

struct GenericResponse<T: Content>: Content {
    let data: T
    var status: StatusResponse = .ok
    
    static func failure<T>(data: T) -> GenericResponse<T> {
        let response = GenericResponse<T>(data: data, status: .failure)
        return response
    }
}

enum StatusResponse: Int, Content {
    case ok = 0
    case failure = 1
}
