//
//  MainTabView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CoursesView()
                .tabItem {
                    Label("Courses", systemImage: "book.fill")
                }
                .tag(0)

            GradesView()
                .tabItem {
                    Label("Grades", systemImage: "chart.bar.fill")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
        .tint(.teal)
    }
}

#Preview {
    MainTabView()
}
