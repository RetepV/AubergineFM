//
//  ToolbarViewView.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//  
//

import SwiftUI

struct ToolbarView: View {
    
    @State
    var viewModel = ViewModel() as ViewModelProtocol
    
    @State
    private var showTrashItemsAlert = false
    @State
    private var trashItemsDelegate: DropFileItemsOnTrashBinDropDelegate? = nil
    
    @EnvironmentObject
    var dragDropCoordinator: MultiSelectDragDropCoordinator<FileManagerItemModel>
    
    var body: some View {
        HStack(spacing: 0) {
            barButton(imageName: "Icons/Action/delete", label: "Delete") {
            }
            .onDrop(of: [.fileManagerItemModel],
                    delegate: DropFileItemsOnTrashBinDropDelegate(fileItems: dragDropCoordinator.multiSelectedItems,
                                                                  onConfirmDrop: { delegate in
                guard let delegate = delegate as? DropFileItemsOnTrashBinDropDelegate<FileManagerItemModel> else { return }
                trashItemsDelegate = delegate
                showTrashItemsAlert = true
            }, onConfirmItem: { delegate, item, newFileName in
                print("onConfirmItem: \(item) newFileName: \(newFileName)")
            }, onDropped: { delegate, result in
                print("onDeleted: \(result)")
            }, onComplete: { delegate, result in
                print("onComplete: \(result)")
                dragDropCoordinator.dropCompleted()
            }))
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(Color("FileManager/Toolbar/Background"))
        .onDrop(of: [.fileManagerItemModel], delegate: ForbiddenDropDelegate())
        .alert("Trash items",
               isPresented: $showTrashItemsAlert,
               presenting: trashItemsDelegate,
               actions: { delegate in
            Button("YES") {
                delegate?.acceptDrop()
            }
            Button("NO") {
                delegate?.cancelDrop()
            }
        }, message: { delegate in
            Text("Are you sure you want to trash \((delegate?.numberOfItemsToDrop ?? 0) > 1 ? "these items" : "this item")?\n\n\((delegate?.listOfItemNamesToDrop ?? []).joined(separator: ", "))")
        })
    }
    
    func barButton(imageName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            Image(imageName, bundle: Bundle.main)
                .frame(width: 42, height: 42)
                .foregroundStyle(Color("FileManager/Toolbar/Button/Foreground"))
        })
        .accessibilityLabel(label)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color("FileManager/FileBrowser/Border"), lineWidth: 1)
        )
        .frame(width: 44, height: 44)
    }
}

#Preview {
    ToolbarView()
}

