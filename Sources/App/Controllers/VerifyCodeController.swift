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
        let basicAuthMiddleware = User.authenticator()
        
        let loginRoute = routes.grouped("api", "login")
        let basicAuthGroup = loginRoute.grouped(
            basicAuthMiddleware
        )
        
        basicAuthGroup.post(use: loginHandler)
        
        //Token Auth
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        
        let tokenRoute = routes.grouped("api", "token", "valid")
        let tokenAuthGroup = tokenRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware
        )
        
        tokenAuthGroup.get(use: tokenValid)
    }
    
    func loginHandler(_ req: Request) async throws -> GenericResponse<VerificationCode.Output> {
        do {
            let user = try req.auth.require(User.self)
            let token = try Token.generate(for: user)
            try await token.save(on: req.db)
            return createResponseToken(isCorrect: true, token: token, user: user)
        } catch {
            return createResponseToken(isCorrect: false, token: nil, user: nil)
        }
    }
    
    func tokenValid(_ req: Request) throws -> HTTPStatus {
        _ = try req.auth.require(User.self)
        return .ok
    }
    
    
    //MARK: - Helpers
    
    private func createResponseToken(isCorrect: Bool, token: Token?, user: User?) -> GenericResponse<VerificationCode.Output> {
        let user = user != nil ? User.Public(from: user!) : nil
        let responseObject = VerificationCode.Output(isCodeCorrect: isCorrect, user: user, token: token)
        return GenericResponse(data: responseObject)
    }
    
}
