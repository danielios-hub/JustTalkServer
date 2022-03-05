//
//  StaticFilesController.swift
//  
//
//  Created by Daniel Gallego Peralta on 5/3/22.
//

import Vapor

struct StaticFilesController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(
            "Images",
             ":imageID",
            use: serveImage
        )
    }
    
    func serveImage(_ req: Request) -> Response {
        let id = req.parameters.get("imageID")!
        let directory = req.application.directory.workingDirectory
        let imagePath = Constants.imageURL(with: directory, imageName: id)
        return req.fileio.streamFile(at: imagePath)
    }
}
