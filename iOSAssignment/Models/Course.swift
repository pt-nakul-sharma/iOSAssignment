//
//  Course.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

struct Course: Decodable, Identifiable, Hashable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: Int
    let fullname: String
    let shortname: String
    let progress: Double?
    let courseimage: String?
    let overviewfiles: [OverviewFile]?

    var displayImage: String? {
        if let courseimage, !courseimage.isEmpty {
            return courseimage
        }
        return overviewfiles?.first?.fileurl
    }

    var progressPercentage: Double {
        return progress ?? 0.0
    }
}

struct OverviewFile: Decodable {
    let fileurl: String?
    let filename: String?
    let mimetype: String?
}
