//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 13/1/22.
//

import Vapor
import Fluent

public func sockets(_ app: Application) {
    app.webSocket("user-notifications") { req, ws in
        debugPrint("ws trying to connect")
        
        guard let request = try? req.query.decode(SocketRequest.self),
              let token = try? await Token.query(on: app.db)
                            .filter(\.$value == request.token)
                            .with(\.$user)
                            .first()
        else {
            _ = ws.close(code: .unacceptableData)
            return
        }
        
        let user = token.user
        let userID = user.id!
        debugPrint("ws connected user \(user.phoneNumber)")
        ws.pingInterval = .seconds(15)
        
        NotificationSocketsManager.shared.insert(id: userID, on: ws)
        
        _ = ws.onClose.always { result in
            debugPrint("ws disconnected")
            NotificationSocketsManager.shared.remove(id: userID)
        }
        
    }
}
