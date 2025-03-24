//
//  ToolbarViewModel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//  
//

import Foundation
import SwiftUI

extension ToolbarView {
    
    protocol ViewModelProtocol {
    }
    
    @Observable
    class ViewModel: ViewModelProtocol {
        
        // MARK: - Public
        
        // MARK: - Private
        
        private var model = ToolbarModel()
    }
}

