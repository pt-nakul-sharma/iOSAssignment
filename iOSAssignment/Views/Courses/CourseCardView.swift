//
//  CourseCardView.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import SwiftUI

struct CourseCardView: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Course Image
            courseBanner
                .frame(height: 140)
                .clipped()

            // Course Info
            VStack(alignment: .leading, spacing: 8) {
                Text(course.fullname)
                    .font(.headline)
                    .lineLimit(2)

                Text(course.shortname)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(course.progressPercentage))%")
                            .font(.caption2.bold())
                            .foregroundStyle(.tint)
                    }

                    ProgressView(value: course.progressPercentage, total: 100)
                        .tint(progressColor)
                }
            }
            .padding(12)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
    }

    private var courseBanner: some View {
        let colors = bannerColors(for: course.id)
        return ZStack {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Text(courseInitials)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Image(systemName: courseIcon)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private var courseInitials: String {
        let words = course.shortname.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(course.shortname.prefix(2)).uppercased()
    }

    private var courseIcon: String {
        let name = course.shortname.lowercased()
        if name.contains("ai") || name.contains("ml") { return "brain" }
        if name.contains("web") { return "globe" }
        if name.contains("data") { return "chart.bar.fill" }
        if name.contains("mob") { return "iphone" }
        if name.contains("sec") { return "lock.shield.fill" }
        if name.contains("ux") || name.contains("ui") { return "paintbrush.fill" }
        return "book.fill"
    }

    private func bannerColors(for id: Int) -> [Color] {
        let palettes: [[Color]] = [
            [.teal, .blue],
            [.purple, .indigo],
            [.orange, .red],
            [.green, .teal],
            [.pink, .purple],
            [.blue, .cyan],
            [.indigo, .blue],
        ]
        return palettes[abs(id) % palettes.count]
    }

    private var progressColor: Color {
        let p = course.progressPercentage
        if p >= 75 { return .green }
        if p >= 40 { return .orange }
        return .teal
    }
}
