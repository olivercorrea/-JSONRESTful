//
//  SessionManager.swift
//  JSONRESTful
//
//  Created by Joshua Tapia on 1/12/23.
//

import Foundation

class SessionManager {
    static let shared = SessionManager()

    var usuario: Users?

    private init() {}
}
