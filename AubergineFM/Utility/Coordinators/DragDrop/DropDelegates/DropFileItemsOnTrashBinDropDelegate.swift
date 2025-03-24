//
//  DropFileItemsOnTrashBinDropDelegate.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 15-12-2024.
//

import SwiftUI

class DropFileItemsOnTrashBinDropDelegate<T>: InteractiveDropDelegate where T: FileManagerItemModel {
        
    private enum DropState {
        case idle
        case performDropRequested
        case performingDrop
        case confirmingItem
    }

    private var dropState: DropState = .idle
    
    private let droppedItems: [T]

    private let onConfirmDrop: (_ delegate: DropFileItemsOnTrashBinDropDelegate) -> Void
    private let onConfirmItem: (_ delegate: DropFileItemsOnTrashBinDropDelegate, _ item: T, _ newFileName: String) -> Void
    private let onDropped: (_ delegate: DropFileItemsOnTrashBinDropDelegate, _ result: Result<T, Error>) -> Void
    private let onComplete: (_ delegate: DropFileItemsOnTrashBinDropDelegate, _ result: Result<Void, Error>) -> Void

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
        nil
    }
    
    var confirmingDestinationName: String? {
        nil
    }

    required init(fileItems: [T],
                  destinationFolderFileURL: URL? = nil,
                  onConfirmDrop: @escaping (_ delegate: any InteractiveDropDelegate) -> Void,
                  onConfirmItem: @escaping (_ delegate: any InteractiveDropDelegate, _ item: T, _ newFileName: String) -> Void,
                  onDropped: @escaping (any InteractiveDropDelegate, Result<T, any Error>) -> Void,
                  onComplete: @escaping (any InteractiveDropDelegate, Result<Void, any Error>) -> Void) {
        self.droppedItems = fileItems
        self.onConfirmDrop = onConfirmDrop
        self.onConfirmItem = onConfirmItem
        self.onDropped = onDropped
        self.onComplete = onComplete
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
            return DropProposal(operation: .move)
        }
        return DropProposal(operation: .forbidden)
    }
    
    func acceptDrop() {
        guard droppedItems.count > 0,
              dropState == .performDropRequested else {
            dropState = .idle
            return
        }

        dropState = .performingDrop
        
        var fullSuccess: Bool = true
        
        for item in droppedItems {
            do {
                try FileManager.default.removeItem(at: item.fileURL)
                onDropped(self, .success(item))
            }
            catch {
                print("Error '\(error)' removing item: \(item.filenameForDisplay)")
                fullSuccess = false
                onDropped(self, .failure(ErrorDefinitionRegistry.dropFailedForItem(item)))
            }
        }
        
        dropState = .idle
        
        onComplete(self, fullSuccess ? .success(()) : .failure(ErrorDefinitionRegistry.dropUnsuccessfull))
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
    
    func acceptItem() {
        // Not necessary
    }
    
    func rejectItem() {
        // Not necessary
    }
    
    func renameItem(to newFileName: String) {
        // Not necessary
    }
}
