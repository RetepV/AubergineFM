//
//  URLHistoryManager.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//

import Foundation

final class URLHistoryManager: HistoryManagerProtocol {
    // MARK: - Private
    
    private var internalRootURL: URL
    
    private var urlHistory: [URL] = []
    private var historyIndex: Int = 0
    
    // MARK: - Lifecyle
    
    init(rootURL: URL) {
        // NOTE: We make sure that the url will be treated as a directory.
        self.internalRootURL = URL(filePath: rootURL.path(), directoryHint: .isDirectory)
        resetToRoot()
    }
    
    init(rootURL: URL, filePath: String) {
        self.internalRootURL = URL(filePath: rootURL.path(), directoryHint: .isDirectory).appending(folderPathString: filePath)
        resetToRoot()
    }
    
    // MARK: - Protocol
    
    var history: [URL] {
        return urlHistory
    }
    
    var currentURL: URL {
        return urlHistory[historyIndex]
    }

    var rootURL: URL {
        return internalRootURL
    }
    
    var currentFilePath: String {
        return filePathRelativeToRootURL(fileURL: currentURL) ?? "/"
    }

    @discardableResult func resetToRoot() -> URL {
        urlHistory.removeAll()
        urlHistory.append(internalRootURL)
        historyIndex = 0
        
        return urlHistory[historyIndex]
    }
    
    @discardableResult func browseTo(fileURL: URL) -> URL {
        guard canBrowseTo(fileURL: fileURL) else {
            return urlHistory[historyIndex]
        }
        
        if historyIndex < urlHistory.count - 1 {
            urlHistory.removeSubrange((historyIndex+1)..<urlHistory.endIndex)
        }
        
        urlHistory.append(fileURL)
        historyIndex += 1

        return urlHistory[historyIndex]
    }
    
    @discardableResult func browseBack() -> URL {
        guard canBrowseBack() else {
            return urlHistory[historyIndex]
        }
        
        historyIndex -= 1

        return urlHistory[historyIndex]
    }
    
    @discardableResult func browseForward() -> URL {
        guard canBrowseForward() else {
            return urlHistory[historyIndex]
        }
        
        historyIndex += 1
        
        return urlHistory[historyIndex]
    }
    
    @discardableResult func browseToParent() -> URL {
        guard !isAtRoot() else {
            return urlHistory[historyIndex]
        }
        
        let newURL = urlHistory[historyIndex].deletingLastPathComponent()
        return browseTo(fileURL: newURL)
    }
    
    @discardableResult func browseToRoot() -> URL {
        return browseTo(fileURL: internalRootURL)
    }
    
    @discardableResult func browseToHistoryStart() -> URL {
        guard canBrowseToHistoryStart() else {
            return urlHistory[historyIndex]
        }

        historyIndex = 0
        
        return urlHistory[historyIndex]
    }
    
    @discardableResult func browseToHistoryEnd() -> URL {
        guard canBrowseToHistoryEnd() else {
            return urlHistory[historyIndex]
        }

        historyIndex = urlHistory.count - 1
        
        return urlHistory[historyIndex]
    }
    
    func canBrowseTo(fileURL: URL) -> Bool {
        guard let filePath = fileURL.path().removingPercentEncoding,
              FileManager.default.fileExists(atPath: filePath) else {
            return false
        }
        return true
    }
    
    func canBrowseBack() -> Bool {
        return historyIndex > 0
    }
    
    func canBrowseForward() -> Bool {
        return historyIndex < urlHistory.count - 1
    }
    
    func canBrowseToParent() -> Bool {
        return !isAtRoot()
    }
    
    func canBrowseToRoot() -> Bool {
        return !isAtRoot()
    }

    func canBrowseToHistoryStart() -> Bool {
        return historyIndex > 0
    }
    
    func canBrowseToHistoryEnd() -> Bool {
        return historyIndex < urlHistory.count - 1
    }
    
    func isAtRoot() -> Bool {
        return urlHistory[historyIndex] == internalRootURL
    }
    
    func filePathRelativeToRootURL(fileURL: URL) -> String? {

        if fileURL == internalRootURL {
            return "/"
        }
        
        if let filePath = fileURL.path().removingPercentEncoding,
           let rootPath = internalRootURL.path().removingPercentEncoding {
            return "/".appending(filePath.replacingOccurrences(of: rootPath, with: ""))
        }
        
        return nil
    }
}
