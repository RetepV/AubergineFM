//
//  DropFileItemsOnFileBrowserDropDelegate.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 15-12-2024.
//

import SwiftUI

class DropFileItemsOnFileBrowserDropDelegate<T>: NSObject, InteractiveDropDelegate, FileManagerDelegate where T: FileManagerItemModel {
    
    enum DropState {
        case idle
        case performDropRequested
        case performingDrop
        case confirmingItem
    }
    
    private var dropState: DropState = .idle
    
    private let droppedItems: [T]
    private let destinationFolderFileURL: URL?
    
    private let onConfirmDrop: (_ delegate: DropFileItemsOnFileBrowserDropDelegate) -> Void
    private let onConfirmItem: (_ delegate: DropFileItemsOnFileBrowserDropDelegate, _ item: T, _ newFileName: String) -> Void
    private let onDropped: (_ delegate: DropFileItemsOnFileBrowserDropDelegate, _ result: Result<T, Error>) -> Void
    private let onComplete: (_ delegate: DropFileItemsOnFileBrowserDropDelegate, _ result: Result<Void, Error>) -> Void
    
    private var itemsToDrop: [T] = []
    
    private var overwriteItemIfNecessary: Bool = false
    private var currentlyChosenDestinationName: String?
    
    private var fileManager: FileManager = FileManager()

    var numberOfItemsToDrop: Int {
        droppedItems.count
    }

    var listOfItemNamesToDrop: [String] {
        var itemNamesToDrop = [String]()
        
        for item in droppedItems {
            itemNamesToDrop.append(item.filenameForDisplay)
        }
        
        return itemNamesToDrop
    }
    
    var confirmingSourceItem: T? {
        guard dropState == .confirmingItem else { return nil }
        return itemsToDrop.first
    }
    
    var confirmingDestinationName: String? {
        guard dropState == .confirmingItem else { return nil }
        return currentlyChosenDestinationName
    }

    required init(fileItems: [T],
                  destinationFolderFileURL: URL?,
                  onConfirmDrop: @escaping (any InteractiveDropDelegate) -> Void,
                  onConfirmItem: @escaping (any InteractiveDropDelegate, T, _ newFileName: String) -> Void,
                  onDropped: @escaping (any InteractiveDropDelegate, Result<T, any Error>) -> Void,
                  onComplete: @escaping (any InteractiveDropDelegate, Result<Void, any Error>) -> Void) {
        self.droppedItems = fileItems
        self.destinationFolderFileURL = destinationFolderFileURL
        self.onConfirmDrop = onConfirmDrop
        self.onConfirmItem = onConfirmItem
        self.onDropped = onDropped
        self.onComplete = onComplete
        
        super.init()
        
        fileManager.delegate = self
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        droppedItems.count > 0 && dropState == .idle ? true : false
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard droppedItems.count > 0,
              dropState == .idle else {
            dropState = .idle
            return false
        }
        
        dropState = .performDropRequested
        onConfirmDrop(self)
        
        return false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        if info.hasItemsConforming(to: [.fileManagerItemModel]) {
            return DropProposal(operation: .copy)
        }
        return DropProposal(operation: .forbidden)
    }
    
    func acceptDrop() {
        guard droppedItems.count > 0,
              dropState == .performDropRequested else {
            dropState = .idle
            return
        }
        
        itemsToDrop = droppedItems
        dropState = .performingDrop
        
        dropFirstItem()
    }
    
    func dropFirstItem() {
        guard dropState == .performingDrop else { return }
        
        overwriteItemIfNecessary = false

        if let item = itemsToDrop.first {
            dropItem(item: item)
        }
    }
    
    func dropNextItem() {
        guard dropState == .performingDrop else { return }

        // Removes last one copied.
        itemsToDrop.removeFirst()
        
        overwriteItemIfNecessary = false
        
        if let item = itemsToDrop.first {
            dropItem(item: item)
        }
        else {
            dropState = .idle
            onComplete(self, .success(()))
        }
    }
    
    func dropItem(item: T) {
        guard dropState == .performingDrop || dropState == .confirmingItem,
              let destinationFolderFileURL else {
            dropState = .idle
            return
        }

        if fileManager.fileExists(atPath: destinationFolderFileURL.appendingPathComponent(item.filename).path) {
            dropState = .confirmingItem
            currentlyChosenDestinationName = item.filePath
            onConfirmItem(self, item, item.filePath)
        }
        else {
            do {
                try fileManager.copyItem(at: item.fileURL, to: destinationFolderFileURL.appendingPathComponent(item.filename))
            }
            catch {
                onDropped(self, .failure(ErrorDefinitionRegistry.dropFailedForItem(item)))
            }
            // NOTE: Recursion.
            dropNextItem()
        }
    }
    
    func acceptItem() {
        guard dropState == .confirmingItem,
              let destinationFolderFileURL,
              let item = itemsToDrop.first else {
            dropState = .idle
            return
        }

        // Overwrite the old file.
        do {
            overwriteItemIfNecessary = true
            try fileManager.copyItem(at: item.fileURL, to: destinationFolderFileURL.appendingPathComponent(item.filename))
        }
        catch {
            onDropped(self, .failure(ErrorDefinitionRegistry.dropFailedForItem(item)))
        }
        // NOTE: Recursion.
        dropState = .performingDrop
        dropNextItem()
    }
    
    func rejectItem() {
        guard dropState == .confirmingItem else {
            dropState = .idle
            return
        }
        
        // Skip this item completely.
        
        // NOTE: Recursion.
        dropState = .performingDrop
        dropNextItem()
    }
    
    func renameItem(to newFileName: String) {
        guard dropState == .confirmingItem,
              let destinationFolderFileURL,
              let item = itemsToDrop.first else {
            dropState = .idle
            return
        }
        
        // Check if the proposed new filename also already exists. If so, simply confirm it again.
        if fileManager.fileExists(atPath: destinationFolderFileURL.appendingPathComponent(newFileName).path) {
            dropState = .confirmingItem
            currentlyChosenDestinationName = newFileName
            onConfirmItem(self, item, newFileName)
        }
        else {
            do {
                // Copy to the new filename.
                overwriteItemIfNecessary = false
                try fileManager.copyItem(at: item.fileURL, to: destinationFolderFileURL.appendingPathComponent(newFileName))
            }
            catch {
                onDropped(self, .failure(ErrorDefinitionRegistry.dropFailedForItem(item)))
            }
            // NOTE: Recursion.
            dropNextItem()
        }
    }

    func cancelDrop() {
        // NOTE: Not sure if we could use this to cancel an ongoing drop (e.g. copying a huge number of files
        // NOTE: or something).
        guard droppedItems.count > 0,
              dropState == .performDropRequested /* || dropState == .performingDrop */ else {
            dropState = .idle
            return
        }

        dropState = .idle
        
        onDropped(self, .failure(ErrorDefinitionRegistry.dropCancelled))
        onComplete(self, .failure(ErrorDefinitionRegistry.dropCancelled))
    }
    
    // MARK: - FileManagerDelegate
    
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: any Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        if error.localizedDescription.contains("already exists") {
            return overwriteItemIfNecessary
        }
        
        return false
    }
}

