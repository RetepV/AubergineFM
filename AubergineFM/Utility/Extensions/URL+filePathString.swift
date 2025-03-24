//
//  URL+filePathString.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 16-12-2024.
//

import Foundation

extension URL {
    
    func appending(filePathString: String) -> URL? {
        
        if filePathString.isEmpty || filePathString == "/" {
            return nil
        }
        
        return self.appending(path: filePathString.split(separator: "/").joined(separator: "/"), directoryHint: .notDirectory)
    }
    
    func appending(folderPathString: String) -> URL {
        
        if folderPathString.isEmpty || folderPathString == "/" {
            return URL(filePath: self.path(), directoryHint: .isDirectory)
        }
        
        return self.appending(path: folderPathString.split(separator: "/").joined(separator: "/"), directoryHint: .isDirectory)
    }
}
