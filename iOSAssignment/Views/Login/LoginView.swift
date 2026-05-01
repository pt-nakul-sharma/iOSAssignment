//
//  LoginView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?

    private enum Field {
        case username, password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.tint)

                        Text("iOSAssignment")
                            .font(.largeTitle.bold())

                        Text("Sign in to your LMS account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            TextField("Enter username", text: $viewModel.username)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.username)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .focused($focusedField, equals: .username)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            SecureField("Enter password", text: $viewModel.password)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit { performLogin() }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Error
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: performLogin) {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.body.bold())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.password.isEmpty)

                        Button(action: { viewModel.loginWithToken() }) {
                            Text("Use Demo Token")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(.systemGray6))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func performLogin() {
        focusedField = nil
        Task {
            await viewModel.login()
        }
    }
}

#Preview {
    LoginView()
}
