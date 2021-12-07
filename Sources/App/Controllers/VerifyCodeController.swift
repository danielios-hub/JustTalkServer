//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 7/12/21.
//

import Vapor
import Fluent

struct VerifyCodeController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let route = routes.grouped("api", "code")
        
        route.post("validate", use: postValidateCode)
    }
    
    func postValidateCode(_ req: Request) async throws -> GenericResponse<VerifyCodeResponse> {
        let request = try req.content.decode(VerifyCodeRequest.self)
        
        guard isValidNumber(request.phone) else {
            return createResponse(isCorrect: false, code: request.code)
        }
        
        guard let phone = try await Phone.query(on: req.db)
            .filter(\.$number == request.phone)
            .first() else {
                return createResponse(isCorrect: false, code: request.code)
        }
        
        let codes = try await phone.$code.get(on: req.db)
        let isCorrect = codes.first?.code == request.code
        return createResponse(isCorrect: isCorrect, code: request.code)
    }
    
    private func createResponse(isCorrect: Bool, code: String) -> GenericResponse<VerifyCodeResponse> {
        let responseObject = VerifyCodeResponse(isCodeCorrect: isCorrect, code: code)
        return GenericResponse(data: responseObject)
    }

    private func isValidNumber(_ number: String) -> Bool {
        return Int(number) != nil ? true : false
    }
}

struct VerifyCodeRequest: Content {
    var phone: String
    var code: String
}

struct VerifyCodeResponse: Content {
    var isCodeCorrect: Bool
    var code: String
}
