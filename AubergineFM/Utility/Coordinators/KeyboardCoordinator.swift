//
//  KeyboardCoordinator.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 21-01-2025.
//

import Foundation
import SwiftUI
import Combine


@Observable
final class KeyboardCoordinator: ObservableObject {
    
    // Public
    
    var keyboardHeight: CGFloat = 0

    // Private
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    private(set) var keyboardIsActive: Bool = false
    private var activeEditingViewID: String? = nil
    
    private var keyboardWillShowNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    private var keyboardWillHideNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

    // Lifecycle
    
    init() {
        setupKeyboardNotifications()
        
    }
    
    // Public functions
    
    func startEditing(id: String) {
        self.keyboardIsActive = true
        self.activeEditingViewID = id
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func isEditing(id: String) -> Bool {
        return self.activeEditingViewID == id
    }
    
    func endEditing() {
        if self.keyboardIsActive {
            self.keyboardIsActive = false
            self.activeEditingViewID = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    // Private functions
    
    private func setupKeyboardNotifications() {
        keyboardWillShowNotification.map { notification in
            CGFloat((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.keyboardHeight, on: self)
        .store(in: &cancellableSet)

        keyboardWillHideNotification.map { _ in
            CGFloat(0)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.keyboardHeight, on: self)
        .store(in: &cancellableSet)
    }
}

struct KeyboardCoordinating: ViewModifier {
    @StateObject var coordinator: KeyboardCoordinator

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func keyboardCoordinating(coordinator: KeyboardCoordinator) -> some View {
        modifier(KeyboardCoordinating(coordinator: coordinator))
    }
}

