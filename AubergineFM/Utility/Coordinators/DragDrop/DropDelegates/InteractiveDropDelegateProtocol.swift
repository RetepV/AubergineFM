//
//  InteractiveDropDelegate.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 04-02-2025.
//

import Foundation
import SwiftUI

protocol InteractiveDropDelegate: DropDelegate {
    associatedtype T
    
    var numberOfItemsToDrop: Int { get }
    var listOfItemNamesToDrop: [String] { get }
    
    init(fileItems: [T],
         destinationFolderFileURL: URL?,
         onConfirmDrop: @escaping (_ delegate: any InteractiveDropDelegate) -> Void,
         onConfirmItem: @escaping (_ delegate: any InteractiveDropDelegate, _ item: T, _ newFileName: String) -> Void,
         onDropped: @escaping (_ delegate: any InteractiveDropDelegate, _ result: Result<T, Error>) -> Void,
         onComplete: @escaping (_ delegate: any InteractiveDropDelegate, _ result: Result<Void, Error>) -> Void)
    
    func acceptDrop()
    func cancelDrop()
    
    var confirmingSourceItem: T? { get }
    var confirmingDestinationName: String? { get }

    func acceptItem()
    func rejectItem()
    func renameItem(to newFileName: String)
}
