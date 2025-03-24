//
//  FileManagerItemModel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//

import Foundation
import SwiftUI
import QuickLook
import CoreTransferable

enum FileManagerItemType: Codable {
    
    // File system file types
    
    case genericFolder(_ numberOfItemsInFolder: Int)
    case genericFile(_ sizeInBytes: Int64)
    
    case genericImageFile(_ sizeInBytes: Int64)
    case genericVideoFile(_ sizeInBytes: Int64)
    
    // Concrete file types
    
    case pdfFile(_ sizeInBytes: Int64)
    
    case wordFile(_ sizeInBytes: Int64)
    case excelFile(_ sizeInBytes: Int64)
    
    case pngFile(_ sizeInBytes: Int64)
    case jpgFile(_ sizeInBytes: Int64)
    
    case movFile(_ sizeInBytes: Int64)
    case mp4File(_ sizeInBytes: Int64)
    
    // FTP remote file types
    
    case ftpGenericFolder(_ numberOfItemsInFolder: Int)
    case ftpGenericFile(_ sizeInBytes: Int64)
    
    var iconResource: String {
        switch self {
        case .genericFile, .pdfFile, .wordFile, .excelFile:
            return "Icons/Editor/insert_drive_file"
        case .genericFolder:
            return "Icons/File/folder"
        case .genericImageFile, .pngFile, .jpgFile:
            return "Icons/Image/image"
        case .genericVideoFile, .movFile, .mp4File:
            return "Icons/Notification/ondemand_video"
        case .ftpGenericFile:
            return "Icons/File/cloud"
        case .ftpGenericFolder:
            return "Icons/File/cloud_circle"
        }
    }
}

extension UTType {
    static var fileManagerItemModel: UTType { UTType(exportedAs: "com.retepv.AubergineFM.FileManagerItemModel") }
}

class FileManagerItemModel: NSObject, NSCopying, NSItemProviderReading, NSItemProviderWriting, Identifiable, Codable, Transferable {
    
    // MARK: - Identification. The items are identified by type, rootURL and filePath.
    
    // MARK: Swift Identifiable and Equatable
    
    var id: URL
    
    static func == (lhs: FileManagerItemModel, rhs: FileManagerItemModel) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: ObjC equality
    
    override var hash: Int {
        id.absoluteString.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FileManagerItemModel else { return false }
        return self.hashValue == other.hashValue
    }
    
    // MARK: - Public
    
    var type: FileManagerItemType
    var rootURL: URL
    var filePath: String
    
    // MARK: - Convenience accessors
    
    var specializedType: FileManagerItemType {
        specializedTypeForFileExtension()
    }
    
    var filename: String {
        return String(filePath.split(separator: "/").last ?? "")
    }
    
    var fileExtension: String {
        return String(filename.split(separator: ".").last ?? "")
    }
    
    var filenameForDisplay: String {
        filename.removingPercentEncoding ?? filename
    }
    
    var fileURL: URL {
        FileManagerItemModel.normalizedFileURL(type: type,
                                               rootURL: rootURL,
                                               filePath: filePath)
    }
    
    var fileRelativePath: String {
        String(filePath.split(separator: "/").dropLast().joined(separator: "/"))
    }
    
    var isFolder: Bool {
        switch type {
        case .genericFolder(_):
            return true
        default:
            return false
        }
    }
    
    var sizeForDisplay: (String?, String?) {
        switch type {
        case .genericFile(let sizeInBytes),
                .genericImageFile(let sizeInBytes),
                .genericVideoFile(let sizeInBytes),
                .pdfFile(let sizeInBytes),
                .wordFile(let sizeInBytes),
                .excelFile(let sizeInBytes),
                .pngFile(let sizeInBytes),
                .jpgFile(let sizeInBytes),
                .movFile(let sizeInBytes),
                .mp4File(let sizeInBytes):
            
            let formattedSize = sizeInBytes.formatted(.byteCount(style: .file))
            let splittedSize = formattedSize.split(separator: " ")
            return (String(splittedSize[0]), String(splittedSize[1]))
            
        default:
            return ("", "")
        }
    }
    
    var iconForDisplay: Image {
        return Image(specializedType.iconResource)
    }
    
    var isPreviewable: Bool {
        switch specializedType {
        case .genericFile, .genericFolder, .genericImageFile, .genericVideoFile:
            return false
        case .pdfFile, .wordFile, .excelFile,
                .pngFile, .jpgFile,
                .movFile, .mp4File:
            return true
        case .ftpGenericFile, .ftpGenericFolder:
            return false
        }
    }
    
    var previewItem: QLPreviewItem? {
        switch type {
        case .genericFile, .genericFolder, .genericImageFile, .genericVideoFile:
            return nil
        case .pdfFile, .wordFile, .excelFile,
                .pngFile, .jpgFile,
                .movFile, .mp4File:
            return self as QLPreviewItem
        case .ftpGenericFile, .ftpGenericFolder:
            return nil
        }
    }
    
    override var description: String {
        // return "FileManagerItemModel: \(id) \(type) \(fileURL)"
        return "FileManagerItemModel: \(type) \(fileURL)"
    }
    
    // MARK: - Lifecycle
    
    init(model: FileManagerItemModel) {
        self.type = model.type
        self.rootURL = model.rootURL
        self.filePath = model.filePath
        self.id = FileManagerItemModel.normalizedFileURL(type: model.type,
                                                         rootURL: model.rootURL,
                                                         filePath: model.filePath)
        
        super.init()
    }
    
    init(type: FileManagerItemType, rootURL: URL, filePath: String) {
        self.type = type
        self.rootURL = rootURL
        self.filePath = filePath
        self.id = FileManagerItemModel.normalizedFileURL(type: type,
                                                         rootURL: rootURL,
                                                         filePath: filePath)

        super.init()
    }
    
    init(type: FileManagerItemType, rootURL: URL, fileURL: URL) {
        self.type = type
        self.rootURL = rootURL
        self.filePath = FileManagerItemModel.filePathRelativeToRootURL(fileURL: fileURL, rootURL: rootURL) ?? "[unknown]"
        self.id = FileManagerItemModel.normalizedFileURL(type: type,
                                                         rootURL: rootURL,
                                                         filePath: filePath)

        super.init()
    }
    
    // MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        return FileManagerItemModel(model: self)
    }
    
    // MARK: - NSItemProviderReading
    
    static var readableTypeIdentifiersForItemProvider: [String] = [UTType.fileManagerItemModel.identifier]
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()
        do {
            let subject = try decoder.decode(Self.self, from: data)
            return subject
        }
        catch {
            fatalError()
        }
    }
    
    // MARK: - NSItemProviderWriting
    
    static var writableTypeIdentifiersForItemProvider: [String] = [UTType.fileManagerItemModel.identifier]
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping @Sendable (Data?, (any Error)?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            //Here the object is encoded to a JSON data object and sent to the completion handler
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        }
        catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    // MARK: - Transferable
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .fileManagerItemModel)
    }
    
    // MARK: - Private
    
    private static func filePathRelativeToRootURL(fileURL: URL, rootURL: URL) -> String? {
        if fileURL == rootURL {
            return "/"
        }
        
        if let filePath = fileURL.path().removingPercentEncoding,
           let rootPath = rootURL.path().removingPercentEncoding {
            return "/".appending(filePath.replacingOccurrences(of: rootPath, with: ""))
        }
        
        return nil
    }
    
    private static func normalizedFileURL(type: FileManagerItemType, rootURL: URL, filePath: String) -> URL {
        switch type {
        case .genericFolder(_):
            return rootURL.appending(folderPathString: filePath)
        default:
            return rootURL.appending(filePathString: filePath) ?? rootURL
        }
    }
    
    private func specializedTypeForFileExtension() -> FileManagerItemType {
        switch type {
        case .genericFile(let sizeInBytes),
                .genericImageFile(let sizeInBytes),
                .genericVideoFile(let sizeInBytes),
                .pdfFile(let sizeInBytes),
                .wordFile(let sizeInBytes),
                .excelFile(let sizeInBytes),
                .pngFile(let sizeInBytes),
                .jpgFile(let sizeInBytes),
                .movFile(let sizeInBytes),
                .mp4File(let sizeInBytes):
            
            let fileExtension = filePath.split(separator: ".").last?.lowercased()
            
            switch fileExtension {
            case "pdf":
                return .pdfFile(sizeInBytes)
                
            case "doc", "docx":
                return .wordFile(sizeInBytes)
            case "xls", "xlsx":
                return .excelFile(sizeInBytes)
                
            case "png":
                return .pngFile(sizeInBytes)
            case "jpg", "jpeg":
                return .jpgFile(sizeInBytes)
                
            case "mov":
                return .movFile(sizeInBytes)
            case "mp4", "m4v":
                return .mp4File(sizeInBytes)
                
            default:
                return type
            }
        default:
            return type
        }
    }
}

extension FileManagerItemModel: QLPreviewItem {
    var previewItemURL: URL? {
        return fileURL
    }
}
