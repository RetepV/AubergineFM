//
//  AttributedTextFieldViewModel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 16-12-2024.
//

import Foundation
import SwiftUI

extension AttributedTextFieldView {
    
    protocol ViewModelProtocol {
        
    }
    
    @Observable
    class ViewModel {
        
        // MARK: - Public
        
        // MARK: - Private
        
    }
    
    class TextFieldDelegate: NSObject, UITextFieldDelegate {
        
        var shouldSubmit: (()->Bool)?
        var onSubmit: ((_ text: AttributedString)->Void)?

        init(shouldSubmit: (() -> Bool)? = nil, onSubmit: ((_ text: AttributedString)->Void)? = nil) {
            self.shouldSubmit = shouldSubmit
            self.onSubmit = onSubmit
            
            super.init()
        }
                
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let shouldSubmit, shouldSubmit() {
                textField.resignFirstResponder()
                return true
            }
            return false
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if let onSubmit {
                let newValue = AttributedString(textField.attributedText ?? NSAttributedString())
                onSubmit(newValue)
            }
        }
    }
}

