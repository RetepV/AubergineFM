//
//  FileBrowserViewModel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//
//

import Foundation
import SwiftUI

extension FileBrowserView {
    
    protocol ViewModelProtocol: FileDataItemGridViewDelegate {
        
        var fileDataItems: [FileManagerItemModel] {get}

        func setView(view: FileBrowserView)
        
        func attributedPathString() -> AttributedString
        func currentFolderFileURL() -> URL
        
        func refreshItems()
        
        @discardableResult func resetToRoot() -> URL
        
        @discardableResult func browseTo(relativeFolderURL: URL) -> URL
        @discardableResult func browseTo(absoluteFolderURL: URL) -> URL
        @discardableResult func browseBack() -> URL
        @discardableResult func browseForward() -> URL
        @discardableResult func browseToParent() -> URL
        @discardableResult func browseToRoot() -> URL
        @discardableResult func browseToHistoryStart() -> URL
        @discardableResult func browseToHistoryEnd() -> URL

        func canBrowseTo(relativeFolderURL: URL) -> Bool
        func canBrowseTo(absoluteFolderURL: URL) -> Bool
        func canBrowseBack() -> Bool
        func canBrowseForward() -> Bool
        func canBrowseToParent() -> Bool
        func canBrowseToRoot() -> Bool
        func canBrowseToHistoryStart() -> Bool
        func canBrowseToHistoryEnd() -> Bool
        
        func isAtRoot() -> Bool
    }
    
    @Observable
    class ViewModel: ViewModelProtocol, FileDataProviderDelegate {
        
        // MARK: - Constants
        
        private var pathTextNormalAttributes: AttributeContainer = {
            return AttributeContainer([
                NSAttributedString.Key.foregroundColor: Color("FileManager/FileBrowser/NormalText"),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ])
        }()
        private var pathTextBoldAttributes: AttributeContainer = {
            return AttributeContainer([
                NSAttributedString.Key.foregroundColor: Color("FileManager/FileBrowser/NormalText"),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)
            ])
        }()

        // MARK: - Public
        
        var currentFilePathString: String = ""
        
        var fileDataItems: [FileManagerItemModel] {
            return dataProvider?.fileDataItems ?? []
        }
        
        private var dataProvider: FileDataProviderProtocol? = nil
        
        // MARK: - Private
        
        private var view: FileBrowserView?
        private var model = FileBrowserModel()
        private var historyManager: HistoryManagerProtocol
        
        private var dragSelectionChangedMonitor: AppEventMonitor? = nil
        
        // MARK: - Lifecycle
        
        init(historyManager: HistoryManagerProtocol, dataProvider: FileDataProviderProtocol) {
            
            // TODO: We want the FileBrowserView to be independent of the datasource type. The HistoryManager is quite independent, although it depends on URL schemes,
            // TODO: using a rootURL and a filePath. But the actual dataprovider impleme
            
            self.historyManager = historyManager
            
            
            // TODO: Inject FileDataProvider, but add a dynamically added delegate for the didUpdate, so that we can give ourselves as delegate instead of the creat
            
            self.dataProvider = dataProvider
            self.dataProvider?.delegate = self
            
            self.dragSelectionChangedMonitor = AppEventMonitor(name: "FileBrowserView: refresh items after drag selection changed",
                                                               event: .dragSelectionChanged,
                                                               eventTriggered: { [weak self] event, userData in
                guard let self else { return }
                self.refreshItems()
            })
            AppGlobalEnvironment.shared.eventManager.registerMonitor(dragSelectionChangedMonitor!)
        }
        
        func setView(view: FileBrowserView) {
            self.view = view
        }
        
        // MARK: - ViewModelProtocol
        
        func attributedPathString() -> AttributedString {
            var pathComponents = currentFilePathString.split(separator: "/")
            
            if pathComponents.isEmpty {
                return AttributedString("/", attributes: pathTextBoldAttributes)
            }
            
            let lastPathComponent = pathComponents.removeLast()
            var attributedPath = AttributedString()
            if pathComponents.count > 0 {
                attributedPath.append(AttributedString("/", attributes: pathTextNormalAttributes))
            }
            attributedPath.append(AttributedString(pathComponents.joined(separator: "/"), attributes: pathTextNormalAttributes))
            attributedPath.append(AttributedString("/", attributes: pathTextNormalAttributes))
            attributedPath.append(AttributedString(lastPathComponent, attributes: pathTextBoldAttributes))
            return attributedPath
        }
        
        func currentFolderFileURL() -> URL {
            return historyManager.rootURL.appending(folderPathString: currentFilePathString)
        }
        
        func refreshItems() {
            dataProvider?.update(rootURL: historyManager.rootURL, filePath: historyManager.currentFilePath)
        }
        
        @discardableResult func resetToRoot() -> URL {
            let newURL = historyManager.resetToRoot()
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseTo(relativeFolderURL: URL) -> URL {
            let absoluteURL = historyManager.rootURL.appending(folderPathString: relativeFolderURL.path)
            return browseTo(absoluteFolderURL: absoluteURL)
        }
        
        @discardableResult func browseTo(absoluteFolderURL: URL) -> URL {
            let newURL = historyManager.browseTo(fileURL: absoluteFolderURL)
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseBack() -> URL {
            let newURL = historyManager.browseBack()
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseForward() -> URL {
            let newURL = historyManager.browseForward()
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseToParent() -> URL {
            let newURL = historyManager.browseToParent()
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseToRoot() -> URL {
            let newURL = historyManager.browseToRoot()
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseToHistoryStart() -> URL {
            let newURL = historyManager.browseToHistoryStart()
            refreshItems()
            return newURL
        }
        
        @discardableResult func browseToHistoryEnd() -> URL {
            let newURL = historyManager.browseToHistoryEnd()
            refreshItems()
            return newURL
        }

        func canBrowseTo(relativeFolderURL: URL) -> Bool {
            let absoluteURL = historyManager.rootURL.appending(folderPathString: relativeFolderURL.path)
            return canBrowseTo(absoluteFolderURL: absoluteURL)
        }

        func canBrowseTo(absoluteFolderURL: URL) -> Bool {
            historyManager.canBrowseTo(fileURL: absoluteFolderURL)
        }
        
        func canBrowseBack() -> Bool {
            historyManager.canBrowseBack()
        }
        
        func canBrowseForward() -> Bool {
            historyManager.canBrowseForward()
        }
        
        func canBrowseToParent() -> Bool {
            historyManager.canBrowseToParent()
        }
        
        func canBrowseToRoot() -> Bool {
            historyManager.canBrowseToRoot()
        }
        
        func canBrowseToHistoryStart() -> Bool {
            historyManager.canBrowseToHistoryStart()
        }
        
        func canBrowseToHistoryEnd() -> Bool {
            historyManager.canBrowseToHistoryEnd()
        }
        
        func isAtRoot() -> Bool {
            historyManager.isAtRoot()
        }
        
        // MARK: - Presentable sheets
        
        enum PresentableSheets: Identifiable, SheetEnum {
            
            case errorSheet(String)
            
            var id: String {
                return "\(self)"
            }

            @ViewBuilder
            func view(coordinator: SheetCoordinator<PresentableSheets>) -> some View {
                switch self {
                case .errorSheet(let message):
                    ZStack {
                        Color(.red)
                        // NOTE: We cannot reach the model from here, but it would be nice if we could.
                        // Label(model.sheetLabel, model.sheetImage)
                        Label(message, systemImage: "exclamationmark.triangle")
                    }
                }
            }
        }
        
        // MARK: - Alerts
        
        enum PresentableAlerts: Identifiable {
            var id: String {
                return "\(self)"
            }
            
            case errorAlert(String)
        }
                
        // MARK: - FileDataItemGridViewDelegate
        
        func didDoubleTapItem(_ fileDataItem: FileManagerItemModel) {
            if fileDataItem.isFolder {
                browseTo(absoluteFolderURL: fileDataItem.fileURL)
            }
        }
        
        func didLongPressItem(_ fileDataItem: FileManagerItemModel) {
            // TODO: Preview of menu or something.
        }
                
        // MARK: - FileDataProviderDelegate
        
        func dataProviderDidUpdate(with url: URL) {
            // Force a refresh of our view by updating the current file path string. Don't use the passed URL,
            // but get it fresh from historyManager. It shouldn't matter, but it's always better to get from
            // the one source of truth.
            self.currentFilePathString = historyManager.currentFilePath
        }
    }
}

