//
//  HistoryManagerProtocol.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 15-12-2024.
//

import Foundation

protocol HistoryManagerProtocol {
    
    init(rootURL: URL)
    init(rootURL: URL, filePath: String)
    
    var history: [URL] { get }
    
    var rootURL: URL {get}
    var currentFilePath: String {get}

    var currentURL: URL {get}

    @discardableResult func resetToRoot() -> URL
    
    @discardableResult func browseTo(fileURL: URL) -> URL
    @discardableResult func browseBack() -> URL
    @discardableResult func browseForward() -> URL
    @discardableResult func browseToParent() -> URL
    @discardableResult func browseToRoot() -> URL
    @discardableResult func browseToHistoryStart() -> URL
    @discardableResult func browseToHistoryEnd() -> URL

    func canBrowseTo(fileURL: URL) -> Bool
    func canBrowseBack() -> Bool
    func canBrowseForward() -> Bool
    func canBrowseToParent() -> Bool
    func canBrowseToRoot() -> Bool
    func canBrowseToHistoryStart() -> Bool
    func canBrowseToHistoryEnd() -> Bool
    
    func isAtRoot() -> Bool
    
    func filePathRelativeToRootURL(fileURL: URL) -> String?
}

enum HistoryManagerType {
    case urlHistory
}

class HistoryManagerFactory {
    static func make(type: HistoryManagerType, rootURL: URL, initialFilePath: String) -> HistoryManagerProtocol {

        switch type {
        case .urlHistory:
            return URLHistoryManager(rootURL: rootURL, filePath: initialFilePath)
        }
    }
}
