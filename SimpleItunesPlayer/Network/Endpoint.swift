//
//  Endpoint.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 10/03/25.
//

import Foundation

enum Endpoint {
    case search(term: String)
    
    var url: URL? {
        switch self {
        case .search(let term):
            let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "https://itunes.apple.com/search?term=\(encodedTerm)")
        }
    }
}
