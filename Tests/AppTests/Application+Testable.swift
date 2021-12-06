//
//  File.swift
//  
//
//  Created by Daniel Gallego Peralta on 6/12/21.
//

import XCTVapor
import App

extension Application {
    
    static func testable() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        
        return app
    }
}
