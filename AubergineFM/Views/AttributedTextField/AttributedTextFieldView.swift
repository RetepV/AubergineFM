//
//  AttributedTextFieldView.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 16-12-2024.
//

import Foundation
import SwiftUI

struct AttributedTextFieldView: View, Identifiable {
    
    var id = UUID()
    let isInEditingMode: Bool
    var attributedText: AttributedString

    @State
    var viewModel: ViewModel = ViewModel()
    
    var textFieldDelegate: UITextFieldDelegate?
    
    init(attributedText: AttributedString, editingMode: Bool, onSubmit: @escaping (_ newValue: AttributedString) -> Void) {
        self.attributedText = attributedText
        self.isInEditingMode = editingMode
        
        textFieldDelegate = TextFieldDelegate(shouldSubmit: {
            return true
        }, onSubmit: { newValue in
            onSubmit(newValue)
        })
    }
        
    var body: some View {
        Group {
            if isInEditingMode {
                LegacyUITextField(text: .constant(String(attributedText.characters[...])),
                                  font: .constant(UIFont.systemFont(ofSize: 16, weight: .semibold)),
                                  color: .constant(UIColor(named: "FileManager/FileBrowser/NormalText") ?? UIColor.purple),
                                  textAlignment: .constant(NSTextAlignment.left),
                                  makeFirstResponder: .constant(true),
                                  delegate: textFieldDelegate)
            }
            else {
                LegacyAttributedUILabel(text: .constant(attributedText),
                                        textAlignment: .constant(NSTextAlignment.left),
                                        lineBreakMode: .constant(.byTruncatingMiddle),
                                        lineBreakStrategy: .constant(.standard),
                                        lines: .constant(1))
            }
        }
        .frame(height: 32)
        .id(id)
    }
}

#Preview {
    AttributedTextFieldView(attributedText: AttributedString(stringLiteral: "/Aapnoot/mies"), editingMode: false) { newValue in
    }
}
