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
        
        let basicAuthMiddleware = Phone.authenticator()
        //let guardAuthMiddleware = Phone.guardMiddleware()
        
        let loginRoute = routes.grouped("api", "login")
        let basicAuthGroup = loginRoute.grouped(
            basicAuthMiddleware
            //guardAuthMiddleware
        )
        
        basicAuthGroup.post(use: loginHandler)
    }
    
    func postValidateCode(_ req: Request) async throws -> GenericResponse<VerificationCode.Output> {
        let request = try req.content.decode(VerificationCode.Input.self)
        
        guard PhoneValidator.isValidNumber(request.phone) else {
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
    
    func loginHandler(_ req: Request) async throws -> GenericResponse<VerificationCode.Output> {
        do {
            let phone = try req.auth.require(Phone.self)
            let token = try Token.generate(for: phone)
            try await token.save(on: req.db)
            return createResponseToken(isCorrect: true, token: token)
        } catch {
            return createResponseToken(isCorrect: false, token: nil)
        }
    }
    
    private func createResponse(isCorrect: Bool, code: String) -> GenericResponse<VerificationCode.Output> {
//        let responseObject = VerificationCode.Output(isCodeCorrect: isCorrect, code: code)
        let responseObject = VerificationCode.Output(isCodeCorrect: isCorrect)
        return GenericResponse(data: responseObject)
    }
    
    private func createResponseToken(isCorrect: Bool, token: Token?) -> GenericResponse<VerificationCode.Output> {
        let responseObject = VerificationCode.Output(isCodeCorrect: isCorrect, token: token)
        return GenericResponse(data: responseObject)
    }
    
}
