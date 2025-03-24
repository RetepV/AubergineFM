//
//  FileDataItemViewFactory.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class FileDataItemViewFactory {
    
    // MARK: - Constants
    
    let shadowRadiusNormal: CGFloat = 4
    let shadowRadiusSelected: CGFloat = 8
    let shadowRadiusPreview: CGFloat = 4
    let backgroundColorNormal: Color = Color("FileManager/FileBrowserCell/BackgroundNormal")
    let backgroundColorSelected: Color = Color("FileManager/FileBrowserCell/BackgroundSelected")
    let backgroundColorPreview: Color = Color("FileManager/FileBrowserCell/BackgroundSelected")
    let shadowColorNormal: Color = Color.black
    let shadowColorSelected: Color = Color.yellow
    let shadowColorPreview: Color = Color.black

    // MARK: - View

    @ViewBuilder
    func viewForItem(_ item: FileManagerItemModel,
                     selected: Bool,
                     size: CGSize,
                     dragDropCoordinator: MultiSelectDragDropCoordinator<FileManagerItemModel>,
                     tapAction: ((FileManagerItemModel)->())?,
                     doubleTapAction: ((FileManagerItemModel)->())?,
                     longPressStartAction: ((FileManagerItemModel)->())?,
                     longPressEndAction: ((FileManagerItemModel)->())?) -> some View {
        
        let hypothenuse: CGFloat = sqrt(pow(size.width, 2) + pow(size.height, 2))
        
        switch item.type {
            
        case .genericFolder(let numberOfItemsInFolder), .ftpGenericFolder(let numberOfItemsInFolder):
            
            Button(action: {
            }) {
                folderItemView(for: item,
                               numberOfItemsInFolder: numberOfItemsInFolder,
                               backgroundColor: selected ? backgroundColorSelected : backgroundColorNormal,
                               shadowColor: selected ? shadowColorSelected : shadowColorNormal,
                               shadowRadius: selected ? shadowRadiusSelected : shadowRadiusNormal,
                               size: size)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(LongPressGesture().onChanged { _ in
                longPressStartAction?(item)
            }.onEnded { _ in
                longPressEndAction?(item)
            })
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    doubleTapAction?(item)
                }.exclusively(before: TapGesture(count: 1).onEnded {
                    
                    tapAction?(item)
                })
            )
            .conditionalOnDrag(enabled: selected, {
                NSItemProvider(object: item)
            }, preview: {
                dragDropCoordinator.makePreview(with: item) { imageItem in
                    self.folderItemView(for: item,
                                        numberOfItemsInFolder: numberOfItemsInFolder,
                                        backgroundColor: self.backgroundColorPreview,
                                        shadowColor: self.shadowColorPreview,
                                        shadowRadius: self.shadowRadiusPreview,
                                        size: size)
                }
                .frame(width: hypothenuse + self.shadowRadiusPreview, height: hypothenuse + self.shadowRadiusPreview)
            })
            .onDrop(of: [UTType.fileManagerItemModel],
                    delegate: DropFileItemsOnFolderDropDelegate(fileItems: dragDropCoordinator.multiSelectedItems, on: item))
            
        case .genericFile(_),
                .genericImageFile(_),
                .genericVideoFile(_),
                .pdfFile(_),
                .wordFile(_),
                .excelFile(_),
                .pngFile(_),
                .jpgFile(_),
                .movFile(_),
                .mp4File(_),
                .ftpGenericFile(_):
            
            Button(action: {
            }) {
                fileItemView(for: item,
                             backgroundColor: selected ? backgroundColorSelected : backgroundColorNormal,
                             shadowColor: selected ? shadowColorSelected : shadowColorNormal,
                             shadowRadius: selected ? shadowRadiusSelected : shadowRadiusNormal,
                             size: size)
            }
            .buttonStyle(.plain)
            //.draggable(item)
            .simultaneousGesture(LongPressGesture().onChanged { _ in
                longPressStartAction?(item)
            }.onEnded { _ in
                longPressEndAction?(item)
            })
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    doubleTapAction?(item)
                }.exclusively(before: TapGesture(count: 1).onEnded {
                    tapAction?(item)
                })
            )
            .conditionalOnDrag(enabled: selected, {
                NSItemProvider(object: item)
            }, preview: {
                dragDropCoordinator.makePreview(with: item) { imageItem in
                    self.fileItemView(for: item,
                                      backgroundColor: self.backgroundColorPreview,
                                      shadowColor: self.shadowColorPreview,
                                      shadowRadius: self.shadowRadiusPreview,
                                      size: size)
                }
                .frame(width: hypothenuse + self.shadowRadiusPreview, height: hypothenuse + self.shadowRadiusPreview)
            })
            .onDrop(of: [UTType.fileManagerItemModel], delegate: DropFileItemsOnFileDropDelegate(fileItems: dragDropCoordinator.multiSelectedItems, on: item))
        }
    }
    
    
    @ViewBuilder
    private func folderItemView(for item: FileManagerItemModel,
                                numberOfItemsInFolder: Int,
                                backgroundColor: Color,
                                shadowColor: Color,
                                shadowRadius: CGFloat,
                                size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
                .frame(width: size.width, height: size.height)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 0)
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(Color.clear)
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: 2, height:0)
                        .foregroundStyle(Color.clear)
                    item.iconForDisplay
                        .frame(width: 22, height: 22)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(String(numberOfItemsInFolder))
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Color("FileManager/FileBrowserCell/SubText"))
                        Text("files")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Color("FileManager/FileBrowserCell/SubText"))
                    }
                    Rectangle()
                        .frame(width: 2, height:0)
                        .foregroundStyle(Color.clear)
                }
                .frame(width: size.width, height: 22, alignment: .leading)
                VStack(spacing:0) {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(Color.clear)
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 2, height:0)
                            .foregroundStyle(Color.clear)
                        Text(item.filenameForDisplay)
                            .font(.system(size: 12, weight: .semibold, design: .none))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .truncationMode(.middle)
                            .foregroundStyle(Color("FileManager/FileBrowserCell/NormalText"))
                            .frame(maxWidth: .infinity, maxHeight:.infinity, alignment: .init(horizontal: .leading, vertical: .center))
                        Rectangle()
                            .frame(width: 2, height:0)
                            .foregroundStyle(Color.clear)
                    }
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(Color.clear)
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    @ViewBuilder
    private func fileItemView(for item: FileManagerItemModel,
                              backgroundColor: Color,
                              shadowColor: Color,
                              shadowRadius: CGFloat,
                              size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
                .frame(width: size.width, height: size.height)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 0)
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(Color.clear)
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: 2, height:0)
                        .foregroundStyle(Color.clear)
                    item.iconForDisplay
                        .frame(width: 22, height: 22)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        let (size, unit) = item.sizeForDisplay
                        Text(size ?? "?")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Color("FileManager/FileBrowserCell/SubText"))
                        Text(unit ?? "bytes")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Color("FileManager/FileBrowserCell/SubText"))
                    }
                    Rectangle()
                        .frame(width: 2, height:0)
                        .foregroundStyle(Color.clear)
                }
                .frame(width: size.width, height: 22, alignment: .leading)
                VStack(spacing:0) {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(Color.clear)
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 2, height:0)
                            .foregroundStyle(Color.clear)
                        Text(item.filenameForDisplay)
                            .font(.system(size: 12, weight: .semibold, design: .none))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .truncationMode(.middle)
                            .foregroundStyle(Color("FileManager/FileBrowserCell/NormalText"))
                            .frame(maxWidth: .infinity, maxHeight:.infinity, alignment: .init(horizontal: .leading, vertical: .center))
                        Rectangle()
                            .frame(width: 2, height:0)
                            .foregroundStyle(Color.clear)
                    }
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(Color.clear)
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }
}
