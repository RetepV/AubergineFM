//
//  MainScreenView.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//
//

import SwiftUI

struct MainScreenView: View {
    
    @State
    var viewModel = ViewModel() as ViewModelProtocol
    @State
    var path: String = ""
    
    @StateObject
    var sheetCoordinator: SheetCoordinator<ViewModel.PresentableSheets> = .init()
    @StateObject
    var keyboardCoordinator: KeyboardCoordinator = .init()
    @StateObject
    var dragDropCoordinator: MultiSelectDragDropCoordinator<FileManagerItemModel> = .init()
    
    var body: some View {
        
        VStack(spacing:0) {
            Spacer()
            
            TabView {
                FileBrowserView(id: "TopFileManager",
                                historyManager: HistoryManagerFactory.make(type: .urlHistory,
                                                                           rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                           initialFilePath: "/"),
                                dataProvider: AppSandboxFileDataProvider(rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                         filePath: "/"))
                .frame(width: UIScreen.main.bounds.width)
                FileBrowserView(id: "TopFTPFileManager",
                                historyManager: HistoryManagerFactory.make(type: .urlHistory,
                                                                           rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                           initialFilePath: "/"),
                                dataProvider: AppSandboxFileDataProvider(rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                         filePath: "/"))
                .frame(width: UIScreen.main.bounds.width)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            if viewModel.model.showsDualFilemanagers {
                TabView() {
                    FileBrowserView(id: "BottomFileManager",
                                    historyManager: HistoryManagerFactory.make(type: .urlHistory,
                                                                               rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                               initialFilePath: "/"),
                                    dataProvider: AppSandboxFileDataProvider(rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                             filePath: "/"))
                    .frame(width: UIScreen.main.bounds.width)
                    FileBrowserView(id: "BottomFTPFileManager",
                                    historyManager: HistoryManagerFactory.make(type: .urlHistory,
                                                                               rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                               initialFilePath: "/"),
                                    dataProvider: AppSandboxFileDataProvider(rootURL: URL(fileURLWithPath: NSHomeDirectory()),
                                                                             filePath: "/"))
                    .frame(width: UIScreen.main.bounds.width)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            if viewModel.model.showsBottomToolbar {
                ToolbarView()
            }
            Spacer()
        }
        .background(Color("FileManager/MainScreen/Background"))
        .sheetCoordinating(coordinator: sheetCoordinator)
        .environmentObject(keyboardCoordinator)
        .environmentObject(dragDropCoordinator)
    }
}

#Preview {
    MainScreenView()
}

