//
//  RootView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct RootView: View {
    private let authManager = AuthManager.shared

    var body: some View {
        if authManager.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
