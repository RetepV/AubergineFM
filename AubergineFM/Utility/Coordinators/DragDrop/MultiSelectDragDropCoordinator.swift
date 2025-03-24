//
//  MultiSelectDragDropCoordinator.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 27-01-2025.
//

import Foundation
import SwiftUI

@Observable
class MultiSelectDragDropCoordinator<T: Hashable>: ObservableObject, CustomDebugStringConvertible {

    private(set) var multiSelectedItems: [T] = []

    func addToSelection(_ item: T) {
        if !haveItem(item) {
            purgeNonRelatedItems(item)
            multiSelectedItems.append(item)
            AppGlobalEnvironment.shared.eventManager.notifyMonitors(event: .dragSelectionChanged, userData: nil)
        }
    }
    
    func removeFromSelection(_ item: T) {
        if let index = selectedItemIndex(item) {
            multiSelectedItems.remove(at: index)
            AppGlobalEnvironment.shared.eventManager.notifyMonitors(event: .dragSelectionChanged, userData: nil)
        }
    }
    
    func clearSelection() {
        multiSelectedItems.removeAll()
        print(self.debugDescription)
        AppGlobalEnvironment.shared.eventManager.notifyMonitors(event: .dragSelectionChanged, userData: nil)
    }
    
    func isSelected(_ item: T) -> Bool {
        return haveItem(item)
    }
    
    func itemProvider(for item: T) -> NSItemProvider {
        if haveItem(item), let providerItem = item as? NSItemProviderWriting {
            return NSItemProvider(object: providerItem)
        }
        return NSItemProvider()
    }
    
    func dropCompleted() {
        clearSelection()
        AppGlobalEnvironment.shared.eventManager.notifyMonitors(event: .dropCompleted, userData: nil)
    }
    
    @ViewBuilder
    func makePreview(with draggedItem: T, imageProvider: @escaping (_ imageItem: T) -> some View) -> some View where T: FileManagerItemModel {
        if multiSelectedItems.count == 0 {
            EmptyView()
        }
        else {
            ZStack {
                ForEach(multiSelectedItems) { selectedItem in
                    if selectedItem !== draggedItem {
                        // NOTE: The initial idea was to use a counter, increment it every ForEach loop, and rotate
                        // NOTE: even images right and uneven images left. However, for some reason the ForEach visits
                        // NOTE: every item in multiSelectdItems *twice*, which cancels the whole idea.
                        // NOTE: So therefore this kind of weird part in the algorithm: (1 + Int.random(in: 0...1) * -2).
                        // NOTE: That generates either 1 or -1 at random. The whole algorithm therefore generates a
                        // NOTE: number from either -30...-10 or 10...30, which gives at least a not-so boring effect.
                        imageProvider(selectedItem)
                            .rotationEffect(.degrees(CGFloat(Int.random(in: 10...30) * (1 + Int.random(in: 0...1) * -2))))
                            .opacity(0.66)
                    }
                }
                imageProvider(draggedItem)
            }
        }
    }

    // MARK: - Private
    
    private func haveItem(_ item: T) -> Bool {
        return multiSelectedItems.contains(item)
    }
                                            
    private func selectedItemIndex(_ item: T) -> Int? {
        if let index = multiSelectedItems.firstIndex(of: item) {
            return index
        }
        
        return nil
    }
    
    // Purge items that are unrelated to the given item.
    // - Items from a different folder.
    // - Items of different type.
    private func purgeNonRelatedItems(_ item: T) {
        
    }

    var debugDescription: String {
        return "MultiSelectDragDropCoordinator<\(Unmanaged.passUnretained(self).toOpaque())> (\(multiSelectedItems.count) selected items - \(multiSelectedItems)"
    }
}
