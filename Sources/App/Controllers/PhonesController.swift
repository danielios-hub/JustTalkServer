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
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Phone]> {
        return Phone.query(on: req.db).all()
    }
   
    func validatePhone(_ req: Request) throws -> EventLoopFuture<GenericResponse<PhoneResponse>> {
        let phone = try req.content.decode(PhoneRequest.self)
        
        guard isValidNumber(phone.number) else {
            let responseObject = PhoneResponse(isNumberValid: false, phoneNumber: phone.number)
            let response = GenericResponse(data: responseObject)
            return req.eventLoop.makeSucceededFuture(response)
        }
        
        return Phone.query(on: req.db)
            .filter(\.$number == phone.number)
            .first()
            .unwrap(or: PhoneError.noExisting)
            .flatMapError { error in
            let newPhone = Phone(number: phone.number)
            return newPhone.save(on: req.db).map { return newPhone }
            }.map {
                let responseObject = PhoneResponse(isNumberValid: true, phoneNumber: $0.number)
                return GenericResponse(data: responseObject)
            }

    }
    
    private func isValidNumber(_ number: String) -> Bool {
        return Int(number) != nil ? true : false
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
