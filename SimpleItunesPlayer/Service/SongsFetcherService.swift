//
//  SongsFetcherService.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 10/03/25.
//

import Foundation

class SongsFetcherService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = URLSessionNetworkService()) {
        self.networkService = networkService
    }
    
    func fetchSongs<T: SongAdapter>(
        searchTerm: String,
        adapter: T,
        completion: @escaping (Result<[Song], Error>) -> Void
    ) where T.Response: Decodable {
        let endpoint = Endpoint.search(term: searchTerm)
        networkService.request(endpoint) { (result: Result<T.Response, Error>) in
            switch result {
            case .success(let response):
                let songs = adapter.adapt(response: response)
                completion(.success(songs))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
