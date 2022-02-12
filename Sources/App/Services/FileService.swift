//
//  FileService.swift
//  
//
//  Created by Daniel Gallego Peralta on 12/2/22.
//

import Foundation

public protocol FileService {
    func createDirectoryIfNeeded(at path: String) throws
}

public struct FileServiceImpl: FileService {
    static public let shared = FileServiceImpl()
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func createDirectoryIfNeeded(at path: String) throws {
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(
                at: URL(fileURLWithPath: path),
                withIntermediateDirectories: true,
                attributes: nil)
        }
    }
    
}
