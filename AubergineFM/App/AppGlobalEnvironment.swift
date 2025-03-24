//
//  AppGlobalEnvironment.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 03-02-2025.
//

// This is the only singleton that we allow.

class AppGlobalEnvironment {
    
    static let shared = AppGlobalEnvironment()
    
    private(set) var eventManager: AppEventMonitorManager
    
    private init() {
        self.eventManager = .init()
    }

    func initializeExplicitly() {
        print("AppGlobalEnvironment initialized explicitly.")
    }
}
