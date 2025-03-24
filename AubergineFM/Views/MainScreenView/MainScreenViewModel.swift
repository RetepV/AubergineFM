//
//  MainScreenViewModel.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 12-12-2024.
//
//

import Foundation
import SwiftUI

extension MainScreenView {
    
    protocol ViewModelProtocol {
        var model: MainScreenModel { get }

        func buttonTapped(coordinator: SheetCoordinator<ViewModel.PresentableSheets>)
    }
    
    @Observable
    class ViewModel: ViewModelProtocol {
        
        // MARK: - Public
                
        func buttonTapped(coordinator: SheetCoordinator<PresentableSheets>) {
            Task {
                await coordinator.presentSheet(.sheet)
            }
        }
        
        // MARK: - Private
        
        private(set) var model = MainScreenModel()
        
        // MARK: - Presentable sheets
        
        enum PresentableSheets: String, Identifiable, SheetEnum {
            
            case sheet
            
            var id: String {
                rawValue
            }
            
            @ViewBuilder
            func view(coordinator: SheetCoordinator<PresentableSheets>) -> some View {
                switch self {
                case .sheet:
                    ZStack {
                        Color(.red)
                        // NOTE: We cannot reach the model from here, but it would be nice if we could.
                        // Label(model.sheetLabel, model.sheetImage)
                        Label("Hallo van onze sheet!", systemImage: "person.crop.circle")
                    }
                }
            }
        }
    }
}

