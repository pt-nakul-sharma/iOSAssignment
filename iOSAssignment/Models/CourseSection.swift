//
//  CourseSection.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

struct CourseSection: Decodable, Identifiable {
    let id: Int
    let name: String
    let summary: String?
    let modules: [CourseModule]?
}

struct CourseModule: Decodable, Identifiable {
    let id: Int
    let name: String
    let modname: String?
    let modplural: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case modname
        case modplural
        case description
    }

    init(id: Int, name: String, modname: String?, modplural: String?, description: String?) {
        self.id = id
        self.name = name
        self.modname = modname
        self.modplural = modplural
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        modname = try container.decodeIfPresent(String.self, forKey: .modname)
        modplural = try container.decodeIfPresent(String.self, forKey: .modplural)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
}
