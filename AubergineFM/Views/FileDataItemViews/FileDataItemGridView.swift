//
//  FileDataItemGridView.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 13-12-2024.
//

import SwiftUI
import UniformTypeIdentifiers

protocol FileDataItemGridViewDelegate {
    func didDoubleTapItem(_ fileDataItem: FileManagerItemModel)
    func didLongPressItem(_ fileDataItem: FileManagerItemModel)
}

struct FileDataItemGridView: View {
    
    @Binding
    var frameSize: CGSize
    
    @Binding
    var itemsPerRow: Int
    
    @Binding
    var topSpacing: CGFloat
    @Binding
    var bottomSpacing: CGFloat
    @Binding
    var rowSpacing: CGFloat
    
    @Binding
    var leadingSpacing: CGFloat
    @Binding
    var trailingSpacing: CGFloat
    
    @Binding
    var minimumItemWidth: CGFloat
    @Binding
    var minimumItemHeight: CGFloat
    @Binding
    var minimumItemSpacing: CGFloat
    
    @Binding
    var fileDataItems: [FileManagerItemModel]

    @State
    var delegate: FileDataItemGridViewDelegate?

    @EnvironmentObject
    var keyboardCoordinator: KeyboardCoordinator
    @EnvironmentObject
    var dragDropCoordinator: MultiSelectDragDropCoordinator<FileManagerItemModel>

    var body: some View {
        
        let (realLeadingSpacing,
             realTrailingSpacing,
             realItemSpacing,
             realItemWidth,
             realItemHeight) = calculateOptimizedSizeAndSpacingParameters()
        
        let realItemSize: CGSize = CGSizeMake(realItemWidth, realItemHeight)
        let numberOfRows: Int = Int(ceil(Double(fileDataItems.count) / Double(itemsPerRow)))
        
        ScrollView {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(width: frameSize.width, height: topSpacing)
                    .foregroundStyle(Color.clear)
                
                // Iterate over rows.
                
                ForEach(0..<numberOfRows, id: \.self) { row in
                    let rowItemIndex: Int = row * itemsPerRow

                    // Row spacer
                    
                    if rowItemIndex != 0 {
                        Rectangle()
                            .frame(width: frameSize.width, height: rowSpacing)
                            .foregroundStyle(Color.clear)
                    }
                    
                    // Horizontal stack with 'itemsPerRow' items. If there are less items than 'itemsPerRow' in the row,
                    // fill it up with filler items.
                    
                    HStack(spacing: 0) {
                        
                        Rectangle()
                            .frame(width: realLeadingSpacing, height: realItemSize.height)
                            .foregroundStyle(Color.clear)
                        
                        ForEach(rowItemIndex..<rowItemIndex+itemsPerRow, id: \.self) { index in
                            if index < fileDataItems.count {
                                
                                // Real item
                                
                                FileDataItemViewFactory().viewForItem(fileDataItems[index],
                                                                      selected: dragDropCoordinator.isSelected(fileDataItems[index]),
                                                                      size: realItemSize,
                                                                      dragDropCoordinator: dragDropCoordinator,
                                                                      tapAction: { item in
                                    if dragDropCoordinator.isSelected(item) {
                                        dragDropCoordinator.removeFromSelection(item)
                                    }
                                    else {
                                        dragDropCoordinator.addToSelection(item)
                                    }
                                    if keyboardCoordinator.keyboardIsActive {
                                        keyboardCoordinator.endEditing()
                                    }
                                }, doubleTapAction: { item in
                                    if keyboardCoordinator.keyboardIsActive {
                                        keyboardCoordinator.endEditing()
                                    }
                                    else {
                                        delegate?.didDoubleTapItem(item)
                                    }
                                }, longPressStartAction: { item in
                                    let _ = print("longPressStartAction: \(item)")
                                    if keyboardCoordinator.keyboardIsActive {
                                        keyboardCoordinator.endEditing()
                                    }
                                    else {
                                        // TODO: Never happens, and probably not really necessary anyway, remove it?
                                    }
                                }, longPressEndAction: { item in
                                    if keyboardCoordinator.keyboardIsActive {
                                        keyboardCoordinator.endEditing()
                                    }
                                    else {
                                        delegate?.didLongPressItem(item)
                                    }
                                })
                            }
                            else {
                                
                                // Filler item
                                
                                Rectangle()
                                    .frame(width: realItemSize.width, height: realItemSize.height)
                                    .foregroundStyle(Color.clear)
                            }
                            if (index % itemsPerRow) != (itemsPerRow - 1) {
                                Rectangle()
                                    .frame(width: realItemSpacing, height: realItemSize.height)
                                    .foregroundStyle(Color.clear)
                            }
                            else {
                                Rectangle()
                                    .frame(width: realTrailingSpacing, height: realItemSize.height)
                                    .foregroundStyle(Color.clear)
                            }
                        }
                    }
                    .frame(width: frameSize.width, height: realItemSize.height)
                }
                
                Rectangle()
                    .frame(width: frameSize.width, height: bottomSpacing)
                    .foregroundStyle(Color.clear)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }
    
    private func calculateOptimizedSizeAndSpacingParameters() -> (leadingSpacing: CGFloat,
                                                                  trailingSpacing: CGFloat,
                                                                  minimumItemSpacing: CGFloat,
                                                                  minimumItemWidth: CGFloat,
                                                                  minimumItemHeight: CGFloat) {
        
        let projectedFullWidth = leadingSpacing + minimumItemWidth * CGFloat(itemsPerRow) + minimumItemSpacing * CGFloat(itemsPerRow - 1) + trailingSpacing
        let frameProjectedItemRatio = frameSize.width / projectedFullWidth
        
        return (leadingSpacing * frameProjectedItemRatio,
                trailingSpacing * frameProjectedItemRatio,
                minimumItemSpacing * frameProjectedItemRatio,
                minimumItemWidth * frameProjectedItemRatio,
                minimumItemHeight * frameProjectedItemRatio)
    }
}

#Preview {
    FileDataItemGridView(frameSize: .constant(CGSize(width: 400, height: 500)),
                         itemsPerRow: .constant(5),
                         topSpacing: .constant(8),
                         bottomSpacing: .constant(8),
                         rowSpacing: .constant(8),
                         leadingSpacing: .constant(8),
                         trailingSpacing: .constant(8),
                         minimumItemWidth: .constant(64),
                         minimumItemHeight: .constant(66),
                         minimumItemSpacing: .constant(8),
                         fileDataItems: .constant([
//                            .init(type: .genericFolder(17),
//                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
//                                  filePath: "Aap"),
                            .init(type: .genericFolder(17),
                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
                                  filePath: "Noot"),
                            .init(type: .genericFolder(17),
                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
                                  filePath: "Aap Noot Mies Wim"),
                            .init(type: .genericFolder(17),
                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
                                  filePath: "Aap Noot Mies Wim Zus Jet Teun Vuur Gijs"),
//                            .init(type: .genericFile(65535),
//                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
//                                  filePath: "1.jpg"),
//                            .init(type: .genericFile(38911),
//                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
//                                  filePath: "C64.jpg"),
//                            .init(type: .genericVideoFile(8689969),
//                                  rootURL: URL(string: "/Users/retepv/Library/Developer/CoreSimulator/Devices/E0D49715-5BDF-42E9-B917-B07C206DE0B6/data/Containers/Data/Application/A09AD34A-E464-4461-A28D-619C0F561D2A/Documents")!,
//                                  filePath: "Screen Recording 2024-12-07 at 20.23.00 - scaled.mp4"),
                         ]))
    .border(Color.red)
}

