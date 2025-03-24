//
//  DropFileItemsOnFileDropDelegate.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 15-12-2024.
//

import SwiftUI

// Special Drop Delegate when dropping a bunch of items on a File Manager Item Model

class DropFileItemsOnFileDropDelegate<T: Hashable>: DropDelegate {
    
    private let droppedItems: [T]
    private let fileDroppedOn: T
    
    required init(fileItems: [T], on file: T) {
        self.droppedItems = fileItems
        self.fileDroppedOn = file
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        
        print("Drop on file: \(fileDroppedOn)")

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
