//
//  GradeItem.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

struct GradeResponse: Decodable {
    let usergrades: [UserGrade]?
    let warnings: [GradeWarning]?
}

struct UserGrade: Decodable {
    let courseid: Int?
    let courseidnumber: String?
    let userid: Int?
    let userfullname: String?
    let gradeitems: [GradeItem]?

    // Injected from enrolled courses since the API doesn't return course name
    var injectedCourseName: String?

    var displayCourseName: String {
        injectedCourseName ?? "Course \(courseid ?? 0)"
    }

    var courseTotalGrade: Double? {
        gradeitems?.first(where: { $0.isCourseTotal })?.graderaw
    }

    private enum CodingKeys: String, CodingKey {
        case courseid, courseidnumber, userid, userfullname, gradeitems
    }
}

struct GradeItem: Decodable, Identifiable {
    let id: Int
    let itemname: String?
    let itemtype: String?
    let itemmodule: String?
    let graderaw: Double?
    let gradeformatted: String?
    let grademin: Double?
    let grademax: Double?
    let percentageformatted: String?
    let feedback: String?

    var isCourseTotal: Bool {
        itemtype == "course"
    }

    var displayName: String {
        if let itemname, !itemname.isEmpty {
            return itemname
        }
        return isCourseTotal ? "Course Total" : "Unnamed Item"
    }

    var displayGrade: String {
        if let gradeformatted, !gradeformatted.isEmpty, gradeformatted != "-" {
            return gradeformatted
        }
        if let graderaw {
            return String(format: "%.1f", graderaw)
        }
        return "—"
    }

    var displayPercentage: String {
        percentageformatted ?? "—"
    }
}

struct GradeWarning: Decodable {
    let message: String?
}
