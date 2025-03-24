//
//  MainScreenModel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//  
//

import Foundation
import SwiftUI

struct MainScreenModel {
    let viewLabel: String = "Hello from MainScreenModel!"
    let buttonLabel: String = "Pop up MainScreenSheet"
    let sheetLabel: String = "Hello from MainScreenSheet!"
    let sheetImage: Image = Image(systemName: "hands.thumbsup.circle")
    
    var showsDualFilemanagers: Bool = true
    var showsBottomToolbar: Bool = true
}
