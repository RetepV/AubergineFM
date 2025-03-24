//
//  Item.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 11-12-2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
