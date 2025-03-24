//
//  ErrorDefinitionRegistry.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 04-02-2025.
//

enum ErrorDefinitionRegistry: Error {
    
    // Drag & drop
    
    case dropCancelled
    case dropFailedForItem(FileManagerItemModel)
    case dropUnsuccessfull
}
