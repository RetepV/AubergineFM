//
//  AppEventManager.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 29-01-2025.
//

import Foundation

@Observable
class AppEventMonitorManager: @unchecked Sendable, ObservableObject {
    
    private let serialQueue = DispatchQueue(label: "AppEventMonitorManagerSerialQueue")
    private let concurrentQueue = DispatchQueue(label: "appEventMonitorManagerConcurrentQueue", attributes: .concurrent)
    
    // NOTE: Unfortunately, we cannot use the property wrapper here and need to do it the 'old' way.
    private var arrayOfWeakMonitors: Array<WeakStorageObject<AppEventMonitor>> = []
    
    init() {
        print("AppEventMonitorManager: init")
    }
    
    func registerMonitor(_ monitor: AppEventMonitor?) {
        serialQueue.async { [weak self] in
            print("AppEventMonitorManager: registerMonitor \(monitor as AppEventMonitor?)")
            if let monitor {
                self?.arrayOfWeakMonitors.append(WeakStorageObject(monitor))
                self?.printRegisteredMonitors()
            }
        }
    }
    
    func unregisterMonitor(_ monitor: AppEventMonitor?) {
        serialQueue.async { [weak self] in
            print("AppEventMonitorManager: unregisterMonitor \(monitor as AppEventMonitor?)")
            if let monitor {
                self?.arrayOfWeakMonitors.removeAll { $0.storage == monitor }
                self?.printRegisteredMonitors()
            }
        }
    }
    
    func notifyMonitors(event: AppEventRegistry, userData: Data?) {
        serialQueue.async { [weak self] in
            guard let self else { return }
            print("AppEventMonitorManager: notifyMonitors \(event)")
            self.printRegisteredMonitors()
            self.arrayOfWeakMonitors
                .filter({ $0.storage?.isOfEvent(event: event) ?? false })
                .forEach { item in
                    self.concurrentQueue.async {
                        item.storage?.eventTriggered(event, userData)
                    }
                }
        }
    }
    
    func printRegisteredMonitors() {
        print("-- Registered monitors (count: \(self.arrayOfWeakMonitors.count)) -----------------")
        for index in 0..<self.arrayOfWeakMonitors.count {
            print("[\(index)]: \(String(describing: self.arrayOfWeakMonitors[index].storage))")
        }
        print("---------------------------------------------------")
    }
}
