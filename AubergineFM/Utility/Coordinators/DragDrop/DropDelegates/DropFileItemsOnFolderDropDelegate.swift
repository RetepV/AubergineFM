//
//  DropFileItemsOnFolderDropDelegate.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 15-12-2024.
//

import SwiftUI

class DropFileItemsOnFolderDropDelegate<T: Hashable>: DropDelegate {

    private let droppedItems: [T]
    private let folderDroppedOn: T
    
    required init(fileItems: [T], on folder: T) {
        self.droppedItems = fileItems
        self.folderDroppedOn = folder
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        
        print("Drop on folder: \(folderDroppedOn)")

        for item in droppedItems {
            print("* item dropped: \(item)")
        }

        return false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if info.hasItemsConforming(to: [.fileManagerItemModel]) {
            return DropProposal(operation: .copy)
        }
        return DropProposal(operation: .forbidden)
    }
}
