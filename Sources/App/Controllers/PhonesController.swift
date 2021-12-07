//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import Vapor
import Fluent

struct PhonesController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let phonesRoute = routes.grouped("api", "phones")
        
        phonesRoute.post("validate", use: validatePhone)
        phonesRoute.get(use: getAllHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [Phone] {
        return try await Phone.query(on: req.db).all()
    }
   
    func validatePhone(_ req: Request) async throws -> GenericResponse<PhoneResponse> {
        let request = try req.content.decode(PhoneRequest.self)
        
        guard isValidNumber(request.number) else {
            let responseObject = PhoneResponse(isNumberValid: false, phoneNumber: request.number)
            return GenericResponse(data: responseObject)
        }
        
        let phoneObject = try await Phone.query(on: req.db)
            .filter(\.$number == request.number)
            .first()
        
        if let phoneObject = phoneObject {
            let responseObject = PhoneResponse(isNumberValid: true, phoneNumber: phoneObject.number)
            return GenericResponse(data: responseObject)
        } else {
            let newPhone = Phone(number: request.number)
            try await newPhone.save(on: req.db)
            let verificationCode = VerificationCode(code: generateVerificationCode(), phoneID: newPhone.id!)
            try await verificationCode.save(on: req.db)
            let responseObject = PhoneResponse(isNumberValid: true, phoneNumber: request.number)
            return GenericResponse(data: responseObject)
            
        }
    }
    
    private func isValidNumber(_ number: String) -> Bool {
        return Int(number) != nil ? true : false
    }
    
    private func generateVerificationCode() -> String {
        return "1111"
    }
    
     
}

enum PhoneError: Error {
    case noExisting
}

struct GenericResponse<T: Content>: Content {
    let data: T
}

struct PhoneRequest: Content {
    let number: String
}

struct PhoneResponse: Content {
    var isNumberValid: Bool
    var phoneNumber: String
}
