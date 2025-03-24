//
//  FileBrowserView.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//
//

import SwiftUI
import UniformTypeIdentifiers

struct FileBrowserView: View, Identifiable {
    
    var id: String
    
    @State
    var viewModel: ViewModelProtocol
    @State
    var gridViewSize: CGSize = CGSizeZero
    @State
    private var alertToShow: ViewModel.PresentableAlerts? = nil
    
    @State
    private var showDropItemsAlert = false
    @State
    private var showFileExistsAlert = false
    @State
    private var dropItemsDelegate: DropFileItemsOnFileBrowserDropDelegate? = nil
    
    
    @StateObject
    var sheetCoordinator = SheetCoordinator<ViewModel.PresentableSheets>()
    
    @EnvironmentObject
    var keyboardCoordinator: KeyboardCoordinator
    @EnvironmentObject
    var dragDropCoordinator: MultiSelectDragDropCoordinator<FileManagerItemModel>
    
    init(id: String, historyManager: HistoryManagerProtocol, dataProvider: FileDataProviderProtocol) {
        self.id = id
        self.viewModel = ViewModel(historyManager: historyManager, dataProvider: dataProvider)
        self.viewModel.setView(view: self)
    }
    
    var body: some View {
        
        return VStack(spacing: 0) {
            
            // Browser button bar
            
            HStack(spacing:0) {
                barButton(imageName: "Icons/Navigation/arrow_back_ios", label: "Browse back", isActive: viewModel.canBrowseBack() && !keyboardCoordinator.keyboardIsActive) {
                    dragDropCoordinator.clearSelection()
                    _ = viewModel.browseBack()
                }
                .id(localUniqueId(name: "browseBack"))
                barButton(imageName: "Icons/Navigation/arrow_forward_ios", label: "Browse forward", isActive: viewModel.canBrowseForward() && !keyboardCoordinator.keyboardIsActive) {
                    dragDropCoordinator.clearSelection()
                    _ = viewModel.browseForward()
                }
                .id(localUniqueId(name: "browseForward"))
                barButton(imageName: "Icons/Navigation/subdirectory_arrow_top_left", label: "Browse to parent", isActive: viewModel.canBrowseToParent() && !keyboardCoordinator.keyboardIsActive) {
                    dragDropCoordinator.clearSelection()
                    _ = viewModel.browseToParent()
                }
                .id(localUniqueId(name: "browseToParent"))
                barButton(imageName: "Icons/AV/fast_rewind", label: "Jump to first", isActive: viewModel.canBrowseToHistoryStart() && !keyboardCoordinator.keyboardIsActive) {
                    dragDropCoordinator.clearSelection()
                    _ = viewModel.browseToHistoryStart()
                }
                .id(localUniqueId(name: "jumpToFirst"))
                barButton(imageName: "Icons/AV/fast_forward", label: "Jump to last", isActive: viewModel.canBrowseToHistoryEnd() && !keyboardCoordinator.keyboardIsActive) {
                    dragDropCoordinator.clearSelection()
                    _ = viewModel.browseToHistoryEnd()
                }
                .id(localUniqueId(name: "jumpToLast"))
                Spacer()
                barButton(imageName: "Icons/Navigation/more_horiz", label: "Open menu", isActive: !keyboardCoordinator.keyboardIsActive) {
                }
            }
            .frame(height: 40)
            .background(Color("FileManager/FileBrowser/BackgroundTop"))
            .id(localUniqueId(name: "browserButtonBar"))
            
            // Browser path field
            
            ZStack {
                Rectangle()
                    .fill(Color("FileManager/FileBrowser/BackgroundTop"))
                HStack {
                    Spacer(minLength: 4)
                    HStack {
                        Spacer(minLength: 4)
                        AttributedTextFieldView(attributedText: viewModel.attributedPathString(),
                                                editingMode: keyboardCoordinator.isEditing(id: localUniqueId(name: "pathTextField")),
                                                onSubmit: { newValue in
                            let pathString = String(newValue.characters[...])
                            let relativeURL = URL(fileURLWithPath: pathString)
                            if viewModel.canBrowseTo(relativeFolderURL: relativeURL) {
                                viewModel.browseTo(relativeFolderURL: relativeURL)
                                keyboardCoordinator.endEditing()
                            }
                            else {
                                // sheetCoordinator.presentSheet(.errorSheet("Cannot navigate to \"\(pathString)\""))
                                alertToShow = .errorAlert("Cannot navigate to \"\(pathString)\", the path does not exist. Please check the spelling, and take care of case sensitivity.")
                            }
                        })
                        .id(localUniqueId(name: "pathTextField"))
                        Spacer(minLength: 4)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("FileManager/FileBrowser/Border"), lineWidth: 1)
                    )
                    Spacer(minLength: 4)
                }
            }
            .frame(height: 32)
            .onTapGesture {
                DispatchQueue.main.async {
                    keyboardCoordinator.startEditing(id: localUniqueId(name: "pathTextField"))
                }
            }
            
            // Browser file grid
            
            ZStack {
                Rectangle()
                    .fill(Color("FileManager/FileBrowser/BackgroundBottom"))
                GeometryReader { geometry in
                    if viewModel.fileDataItems.isEmpty {
                        Text("Unfortunately this folder is empty")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .foregroundColor(Color("FileManager/FileBrowser/NormalText"))
                        
                    } else {
                        FileDataItemGridView(frameSize: .constant(geometry.size),
                                             itemsPerRow: .constant(5),
                                             topSpacing: .constant(8),
                                             bottomSpacing: .constant(8),
                                             rowSpacing: .constant(12),
                                             leadingSpacing: .constant(8),
                                             trailingSpacing: .constant(8),
                                             minimumItemWidth: .constant(64),
                                             minimumItemHeight: .constant(66),
                                             minimumItemSpacing: .constant(12),
                                             fileDataItems: .constant(viewModel.fileDataItems),
                                             delegate: viewModel)
                    }
                }
            }
            .onDrop(of: [.fileManagerItemModel],
                    delegate: DropFileItemsOnFileBrowserDropDelegate(fileItems: dragDropCoordinator.multiSelectedItems,
                                                                     destinationFolderFileURL: viewModel.currentFolderFileURL(),
                                                                     onConfirmDrop: { delegate in
                guard let delegate = delegate as? DropFileItemsOnFileBrowserDropDelegate<FileManagerItemModel> else { return }
                dropItemsDelegate = delegate
                showDropItemsAlert = true
            }, onConfirmItem: { delegate, item, newFileName in
                guard let delegate = delegate as? DropFileItemsOnFileBrowserDropDelegate<FileManagerItemModel> else { return }
                dropItemsDelegate = delegate
                showFileExistsAlert = true
            }, onDropped: { delegate, result in
                print("onDeleted: \(result)")
            }, onComplete: { delegate, result in
                print("onComplete: \(result)")
                dragDropCoordinator.dropCompleted()
            }))
        }
        .onTapGesture {
            DispatchQueue.main.async {
                keyboardCoordinator.endEditing()
            }
        }
        .sheetCoordinating(coordinator: sheetCoordinator)
        .alert(item: $alertToShow) { item in
            switch item {
            case .errorAlert(let message):
                Alert(title: Text(verbatim: "Error"), message: Text(verbatim: message), dismissButton: nil)
            }
        }
        .alert("Copy items",
               isPresented: $showDropItemsAlert,
               presenting: dropItemsDelegate,
               actions: { delegate in
            Button("YES") {
                delegate?.acceptDrop()
                showDropItemsAlert = false
            }
            Button("NO") {
                delegate?.cancelDrop()
                showDropItemsAlert = false
            }
        }, message: { delegate in
            Text("Are you sure you want to copy \((delegate?.numberOfItemsToDrop ?? 0) > 1 ? "these items" : "this item")?\n\n\((delegate?.listOfItemNamesToDrop ?? []).joined(separator: ", "))")
        })
        .alert("File exists",
               isPresented: $showFileExistsAlert,
               presenting: dropItemsDelegate,
               actions: { delegate in
            Button("RENAME") {
                showFileExistsAlert = false
                delegate?.renameItem(to: "doemaarietsvoornu")
            }
            Button("OVERWRITE") {
                showFileExistsAlert = false
                delegate?.acceptItem()
            }
            Button("CANCEL") {
                showFileExistsAlert = false
                delegate?.rejectItem()
            }
        }, message: { delegate in
            Text("A file with the name \(delegate?.confirmingDestinationName ?? "") already exists at the destination.\n\nDo you want to overwrite, rename or cancel?")
        })
    }
    
    func barButton(imageName: String, label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            if isActive {
                Image(imageName, bundle: Bundle.main)
            } else {
                Image(imageName, bundle: Bundle.main).opacity(0.3)
            }
        })
        .disabled(!isActive)
        .accessibilityLabel(label)
        .frame(width: 32, height: 32)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color("FileManager/FileBrowser/Border"), lineWidth: 1)
        )
        .frame(width: 40, height: 40)
        .onDrop(of: [.fileManagerItemModel], delegate: ForbiddenDropDelegate())
    }
    
    func localUniqueId(name: String) -> String {
        return id.appending(name)
    }
}

#Preview {
    FileBrowserView(id: "PreviewFileBrowser",
                    historyManager: HistoryManagerFactory.make(type: .urlHistory,
                                                               rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                               initialFilePath: "/"),
                    dataProvider: AppSandboxFileDataProvider(rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                             filePath: "/"))
}
