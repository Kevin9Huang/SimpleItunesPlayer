//
//  HomePageViewModel.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 11/03/25.
//

import Foundation

final class HomePageViewModel<Adapter: SongAdapter> where Adapter.Response: Decodable {

    private let songsFetcherService: SongsFetcherService
    private let adapter: Adapter
    
    @MainActor var onSongsUpdated: (() -> Void)?
    @MainActor var onSongsSearchError: ((String) -> Void)?
    @MainActor var onLoadingStateChanged: ((Bool) -> Void)?
    private(set) var songs: [Song] = []
    
    init(songsFetcherService: SongsFetcherService, adapter: Adapter) {
        self.songsFetcherService = songsFetcherService
        self.adapter = adapter
    }
    
    func searchSongs(term: String) {
        Task { @MainActor in
            onLoadingStateChanged?(true)
        }
        
        songsFetcherService.fetchSongs(searchTerm: term, adapter: adapter) { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.onLoadingStateChanged?(false)
            }
            
            switch result {
            case .success(let songs):
                self.songs = songs
                Task { @MainActor in
                    self.onSongsUpdated?()
                }
            case .failure(let error):
                let errorMessage = self.getErrorMessage(from: error)
                Task { @MainActor in
                    self.onSongsSearchError?(errorMessage)
                }
            }
        }
    }
    
    private func getErrorMessage(from error: Error) -> String {
        if let networkError = error as? URLError {
            switch networkError.code {
            case .notConnectedToInternet:
                return "No internet connection. Please check your network settings."
            case .timedOut:
                return "The request timed out. Please try again."
            default:
                return "An error occurred. Please try again later."
            }
        } else {
            return "An error occurred. Please try again later."
        }
    }
}
