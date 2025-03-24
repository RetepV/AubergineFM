//
//  FolderChangesMonitor.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 28-01-2025.
//

import Foundation

class FolderChangesMonitor {
    
    private let folderURL: URL
    private let didChange: () -> Void
    
    private var monitorDescriptor: CInt = -1
    private var monitorSource: DispatchSourceFileSystemObject? = nil
    private let monitorQueue = DispatchQueue(label: "FolderChangesMonitorQueue", attributes: .concurrent)
    
    init(folderURL: URL, didChange: @escaping () -> Void) {
        self.folderURL = folderURL
        self.didChange = didChange
    }

    deinit {
        stop()
    }
    
    func start() {
        guard monitorSource == nil, monitorDescriptor == -1 else {
            return
        }
        
        monitorDescriptor = open(folderURL.path, O_EVTONLY)
        monitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitorDescriptor,
                                                                  eventMask: .write,
                                                                  queue: monitorQueue)
        
        monitorSource?.setEventHandler { [weak self] in
            self?.didChange()
        }
        
        monitorSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            close(self.monitorDescriptor)
            self.monitorDescriptor = -1
            self.monitorSource = nil
        }
        
        monitorSource?.resume()
    }
    
    func stop() {
        monitorSource?.cancel()
    }
}
