//
//  ToastView.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import SwiftUI

enum ToastType {
    
    case success(LocalizedStringKey)
    case error(LocalizedStringKey)
    case info(LocalizedStringKey)
    
    var backgroundColor: Color {
        switch self {
            case .success:
                return Color.green.opacity(0.9)
            case .error:
                return Color.red.opacity(0.9)
            case .info:
                return Color.blue.opacity(0.9)
        }
    }
    
    var icon: Image {
        switch self {
            case .success:
                return Image(systemName: "checkmark.circle")
            case .error:
                return Image(systemName: "xmark.octagon")
            case .info:
                return Image(systemName: "info.circle")
        }
    }
    
    var messageKey: LocalizedStringKey {
        switch self {
        case .success(let key), .error(let key), .info(let key):
            return key
        }
    }

}


struct ToastView: View {
    
    let type: ToastType
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            type.icon
                .foregroundStyle(.white)
            
            Text(type.messageKey)
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(type.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal, 16)
    }
}

struct ShowToastAction {
    
    typealias Action = (ToastType, ToastPlacement) -> Void
    let action: Action
    
    func callAsFunction(_ type: ToastType, placement: ToastPlacement = .top) {
        action(type, placement)
    }
}

enum ToastPlacement {
    case top
    case bottom
}

extension EnvironmentValues {
    @Entry var showToast = ShowToastAction(action: { _, _  in })
}

struct ToastModifier: ViewModifier {
    
    @State private var type: ToastType?
    @State private var placement: ToastPlacement = .top
    @State private var dismissTask: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .environment(\.showToast, ShowToastAction(action: { type, placement in
                withAnimation(.easeInOut) {
                    self.type = type
                    self.placement = placement
                }
                
                dismissTask?.cancel()
                
                let task = DispatchWorkItem {
                    withAnimation(.easeInOut) {
                        self.type = nil
                    }
                }
                
                self.dismissTask = task
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
                
            }))
            .overlay(alignment: placement == .top ? .top: .bottom) {
                if let type {
                    ToastView(type: type)
                        .transition(.move(edge: placement == .top ? .top: .bottom).combined(with: .opacity))
                        .padding(.top, 10)
                }
            }
    }
}

extension View {
    func withToast() -> some View {
        modifier(ToastModifier())
    }
}

