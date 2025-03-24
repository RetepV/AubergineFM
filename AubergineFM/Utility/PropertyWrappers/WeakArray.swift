//
//  WeakArray.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 21-01-2025.
//

@propertyWrapper
struct WeakArray<T: AnyObject> {
    
    private var weakCollection: Array<WeakStorageObject<T>> = []
    
    var wrappedValue: Array<T> {
        get {
            return weakCollection.compactMap(\.storage)
        }
        set {
            weakCollection = newValue.map(WeakStorageObject.init)
            // Collect garbage now immediately.
            reap()
        }
    }
    
    mutating func reap() {
        weakCollection.removeAll { $0.storage == nil }
    }
}
