//
//  AuthToken.swift
//  iOSAssignment
//
//  Created by Nakul Sharma on 01/05/26.
//

import Foundation

struct AuthTokenResponse: Decodable {
    let token: String?
    let privatetoken: String?
    let error: String?
    let errorcode: String?
}
