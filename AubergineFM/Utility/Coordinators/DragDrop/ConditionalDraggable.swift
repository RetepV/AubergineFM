//
//  ConditionalDraggable.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 28-01-2025.
//

import Foundation
import SwiftUI

struct ConditionalDraggable<V>: ViewModifier where V : View {
    
    let enabled: Bool
    let data: () -> NSItemProvider
    let preview: () -> V
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content.onDrag(data, preview: preview)
        } else {
            content
        }
    }
}

extension View {
    public func conditionalOnDrag<V>(enabled: Bool, _ data: @escaping () -> NSItemProvider, @ViewBuilder preview: @escaping () -> V) -> some View where V: View {
        self.modifier(ConditionalDraggable(enabled: enabled, data: data, preview: preview))
    }
}
