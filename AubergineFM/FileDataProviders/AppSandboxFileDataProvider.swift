//
//  AppSandboxFileDataProvider.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//

import Foundation
import UniformTypeIdentifiers

@Observable
final class AppSandboxFileDataProvider: FileDataProviderProtocol {
    
    // MARK: - Public
    
    var delegate: (any FileDataProviderDelegate)?
    var fileDataItems: [FileManagerItemModel] = []

    // MARK: - Private
    

    private var folderChangesMonitor: FolderChangesMonitor?
    
    // MARK: Lifecycle
    
    // NOTE: We don't want to hold the rootURL as state data. 'rootURL'' does not really mean anything to us. However, we do
    // NOTE: need the rootURL and filePath as separate entities in order to create a proper  FileManagerItemModel, which needs
    // NOTE: them for its own purposes.
    // NOTE: So pass the path to the file as a rootURL and a separate filePath, which will be appended to the rootURL.
    
    init(rootURL: URL, filePath: String) {
        scanFilesForURL(rootURL: rootURL, filePath: filePath)
    }
            
    func update(rootURL: URL, filePath: String) {
        scanFilesForURL(rootURL: rootURL, filePath: filePath)
    }
    
    // MARK: - Private
    
    private func scanFilesForURL(rootURL: URL, filePath: String) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let folderURL = rootURL.appending(folderPathString: filePath)
            
            strongSelf.folderChangesMonitor?.stop()
            strongSelf.folderChangesMonitor = FolderChangesMonitor(folderURL: folderURL, didChange: { [weak self] in
                self?.update(rootURL: rootURL, filePath: filePath)
            })
            strongSelf.folderChangesMonitor?.start()
            
            let sortedFileList = strongSelf.fetchSortedFiles(folderURL: folderURL)
            
            if let sortedFileList {
                
                var newFileModels: [FileManagerItemModel] = []
                
                for fileURL in sortedFileList {
                    
                    let isFolder = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory!
                    
                    if let isFolder, isFolder {
                        let numberOfItemsInFolder = strongSelf.numberOfItemsInFolder(folderURL: fileURL)
                        newFileModels.append(FileManagerItemModel(type: .genericFolder(numberOfItemsInFolder ?? 0),
                                                                  rootURL: rootURL,
                                                                  fileURL: fileURL.standardizedFileURL))
                    }
                    else {
                        let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize as NSNumber?
                        let fileExtension = fileURL.pathExtension
                        if !fileExtension.isEmpty {
                            let fileUTI = UTType(filenameExtension: fileExtension)!
                            
                            if fileUTI.conforms(to: .image) {
                                newFileModels.append(FileManagerItemModel(type: .genericImageFile(fileSize?.int64Value ?? 0),
                                                                          rootURL: rootURL,
                                                                          fileURL: fileURL.standardizedFileURL))
                            }
                            else if fileUTI.conforms(to: .movie) {
                                newFileModels.append(FileManagerItemModel(type: .genericVideoFile(fileSize?.int64Value ?? 0),
                                                                          rootURL: rootURL,
                                                                          fileURL: fileURL.standardizedFileURL))
                            }
                            else {
                                newFileModels.append(FileManagerItemModel(type: .genericFile(fileSize?.int64Value ?? 0),
                                                                          rootURL: rootURL,
                                                                          fileURL: fileURL.standardizedFileURL))
                            }
                        }
                        else {
                            newFileModels.append(FileManagerItemModel(type: .genericFile(fileSize?.int64Value ?? 0),
                                                                      rootURL: rootURL,
                                                                      fileURL: fileURL.standardizedFileURL))
                        }
                    }
                }
                                
                DispatchQueue.main.async {
                    strongSelf.fileDataItems = newFileModels
                    strongSelf.delegate?.dataProviderDidUpdate(with: folderURL)
                }
            }
        }
    }

    private func fetchSortedFiles(folderURL: URL) -> [URL]? {

        return try? FileManager.default.contentsOfDirectory(at: folderURL,
                                                            includingPropertiesForKeys: [.pathKey,
                                                                                         .isDirectoryKey,
                                                                                         .isRegularFileKey],
                                                            options: [.includesDirectoriesPostOrder,
                                                                      .skipsSubdirectoryDescendants,
                                                                      .skipsPackageDescendants])
        .sorted(by: { lhs, rhs in
            lhs.lastPathComponent < rhs.lastPathComponent
        })
        .sorted(by: { lhs, rhs in
            let leftIsFolder = try? lhs.resourceValues(forKeys: [.isDirectoryKey]).isDirectory!
            let rightIsFolder = try? rhs.resourceValues(forKeys: [.isDirectoryKey]).isDirectory!
            
            if let leftIsFolder, let rightIsFolder {
                return leftIsFolder && !rightIsFolder
            }
            
            return leftIsFolder ?? false
        })
    }
    
    private func numberOfItemsInFolder(folderURL: URL) -> Int? {

        return try? FileManager.default.contentsOfDirectory(at: folderURL,
                                                            includingPropertiesForKeys: [.pathKey,
                                                                                         .isDirectoryKey,
                                                                                         .isRegularFileKey],
                                                            options: [.skipsSubdirectoryDescendants,
                                                                      .skipsPackageDescendants]).count
    }
}
