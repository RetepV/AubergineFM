//
//  ForbiddenDropDelegate.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 15-12-2024.
//

import SwiftUI

class ForbiddenDropDelegate: DropDelegate {
    
    func validateDrop(info: DropInfo) -> Bool {
        true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        return false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .forbidden)
    }
}

