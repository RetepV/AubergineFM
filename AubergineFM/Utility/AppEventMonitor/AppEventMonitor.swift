//
//  AppEventMonitor.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 03-02-2025.
//

import Foundation

class AppEventMonitor: @unchecked Sendable, Equatable, Identifiable {
    
    let name: String
    let event: AppEventRegistry
    let eventTriggered: (_ event: AppEventRegistry, _ userData: Data?) -> Void
    
    init(name: String, event: AppEventRegistry, eventTriggered: @escaping (_ event: AppEventRegistry, _ userData: Data?) -> Void) {
        self.name = name
        self.event = event
        self.eventTriggered = eventTriggered
    }
    
    func isOfEvent(event: AppEventRegistry) -> Bool {
        return self.event == event
    }
    
    static func == (lhs: AppEventMonitor, rhs: AppEventMonitor) -> Bool {
        lhs.id == rhs.id
    }
}
