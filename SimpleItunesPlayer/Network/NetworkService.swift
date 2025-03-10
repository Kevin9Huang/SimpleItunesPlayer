//
//  NetworkService.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 10/03/25.
//

import Foundation

protocol NetworkService {
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, Error>) -> Void
    )
}
