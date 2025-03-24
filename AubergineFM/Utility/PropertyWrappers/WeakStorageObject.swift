//
//  WeakStorageObject.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 21-01-2025.
//


final class WeakStorageObject<T>: @unchecked Sendable, Identifiable, Equatable, Hashable, CustomDebugStringConvertible where T: AnyObject {
    
    var debugDescription: String {
        if let storage = storage {
            return "WeakStorageObject<\(Unmanaged<T>.passUnretained(storage).toOpaque())>: \(storage)"
        }
        return "WeakStorageObject<nil>: nil"
    }

    // Private
    weak var storage: T?
    
    init(_ storage: T) {
        self.storage = storage
    }
    
    static func == (lhs: WeakStorageObject<T>, rhs: WeakStorageObject<T>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

