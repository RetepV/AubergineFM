//
//  LegacyTextField.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 16-12-2024.
//

import Foundation
import SwiftUI

struct LegacyUITextField: UIViewRepresentable {
    typealias UIViewType = UITextField
    
    @Binding var text: String
    @Binding var font: UIFont
    @Binding var color: UIColor
    @Binding var textAlignment: NSTextAlignment
    @Binding var makeFirstResponder: Bool
    
    @State var delegate: UITextFieldDelegate?
    
    func makeUIView(context: Context) -> UITextField {
        UITextField()
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.textColor = color
        uiView.textAlignment = textAlignment
        
        uiView.delegate = delegate
        
        if makeFirstResponder {
            uiView.becomeFirstResponder()
        }
        else {
            uiView.resignFirstResponder()
        }
    }
}
