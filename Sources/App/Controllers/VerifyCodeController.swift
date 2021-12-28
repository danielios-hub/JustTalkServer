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
        //Basic Auth
        let basicAuthMiddleware = Phone.authenticator()
        
        let loginRoute = routes.grouped("api", "login")
        let basicAuthGroup = loginRoute.grouped(
            basicAuthMiddleware
        )
        
        basicAuthGroup.post(use: loginHandler)
        
        //Token Auth
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = Phone.guardMiddleware()
        
        let tokenRoute = routes.grouped("api", "token", "valid")
        let tokenAuthGroup = tokenRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware
        )
        
        tokenAuthGroup.get(use: tokenValid)
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
    
    func tokenValid(_ req: Request) throws -> HTTPStatus {
        _ = try req.auth.require(Phone.self)
        return .ok
    }
    
    
    //MARK: - Helpers
    
    private func createResponse(isCorrect: Bool, code: String) -> GenericResponse<VerificationCode.Output> {
        let responseObject = VerificationCode.Output(isCodeCorrect: isCorrect)
        return GenericResponse(data: responseObject)
    }
    
    private func createResponseToken(isCorrect: Bool, token: Token?) -> GenericResponse<VerificationCode.Output> {
        let responseObject = VerificationCode.Output(isCodeCorrect: isCorrect, token: token)
        return GenericResponse(data: responseObject)
    }
    
}
