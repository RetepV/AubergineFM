//
//  FileDataProviderProtocol.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//

import Foundation

protocol FileDataProviderDelegate {
    func dataProviderDidUpdate(with url: URL)
}

protocol FileDataProviderProtocol {
    
    var delegate: FileDataProviderDelegate? { get set }
    var fileDataItems: [FileManagerItemModel] { get }

    init(rootURL: URL, filePath: String)

    func update(rootURL: URL, filePath: String)
}

enum FileDataProviderType {
    case appSandbox
}

class FileDataProviderFactory {
    static func make(type: FileDataProviderType, initialURL: URL, initialFilePath: String) -> FileDataProviderProtocol {

        switch type {
        case .appSandbox:
            return AppSandboxFileDataProvider(rootURL: initialURL, filePath: initialFilePath)
        }
    }
}
