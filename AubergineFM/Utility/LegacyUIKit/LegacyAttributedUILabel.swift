//
//  LegacyUILabel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 13-12-2024.
//

import Foundation
import SwiftUI

struct LegacyAttributedUILabel: UIViewRepresentable {
    typealias UIViewType = UILabel
    
    @Binding var text: AttributedString
    @Binding var textAlignment: NSTextAlignment
    @Binding var lineBreakMode: NSLineBreakMode
    @Binding var lineBreakStrategy: NSParagraphStyle.LineBreakStrategy
    @Binding var lines: Int
    
    func makeUIView(context: Context) -> UILabel {
        UILabel()
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = NSAttributedString(text)
        uiView.numberOfLines = lines
        uiView.textAlignment = textAlignment
        uiView.lineBreakMode = lineBreakMode
        uiView.lineBreakStrategy = lineBreakStrategy
    }
}
