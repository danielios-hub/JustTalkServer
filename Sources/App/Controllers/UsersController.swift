//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let phonesRoute = routes.grouped("api", "phones")
        
        phonesRoute.post("validate", use: validatePhone)
        phonesRoute.get(use: getAllHandler)
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
    
    //MARK: - Helpers
    
    private func createResponse(isValid: Bool, number: String) -> GenericResponse<User.Output> {
        let responseObject = User.Output(isNumberValid: isValid, phoneNumber: number)
        return GenericResponse(data: responseObject)
    }
}

enum PhoneError: Error {
    case noExisting
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
