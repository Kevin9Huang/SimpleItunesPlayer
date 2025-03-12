//
//  HomePageViewModelTest.swift
//  SimpleItunesPlayerTests
//
//  Created by CMP2024008 on 12/03/25.
//

import XCTest
@testable import SimpleItunesPlayer

final class HomePageViewModelTests: XCTestCase {

    private final class MockSongAdapter: SongAdapter {
        struct Response: Decodable {
            let songs: [MockSongResponse]
        }

        struct MockSongResponse: Decodable {
            let trackName: String
            let artistName: String
            let collectionName: String?
            let artworkUrl100: String
            let previewUrl: String
        }

        func adapt(response: Response) -> [Song] {
            return response.songs.map {
                Song(name: $0.trackName,
                     artist: $0.artistName,
                     album: $0.collectionName,
                     thumbnailUrl: $0.artworkUrl100,
                     previewUrl: $0.previewUrl)
            }
        }
    }

    
    private class MockSongsFetcherService: SongsFetcherService {
        private var result: Result<[Song], Error>
        
        init(result: Result<[Song], Error>) {
            self.result = result
            super.init(networkService: MockNetworkService())
        }
        
        override func fetchSongs<T: SongAdapter>(
            searchTerm: String,
            adapter: T,
            completion: @escaping (Result<[Song], Error>) -> Void
        ) where T.Response: Decodable {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                completion(self.result)
            }
        }
    }
    
    private func makeSUT(
        result: Result<[Song], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HomePageViewModel<MockSongAdapter> {
        let service = MockSongsFetcherService(result: result)
        let adapter = MockSongAdapter()
        let sut = HomePageViewModel(songsFetcherService: service, adapter: adapter)
        trackForMemoryLeaks(sut, file:file, line: line)
        return sut
    }
    
    @MainActor
    func test_searchSongs_success() {
        let expectedSongs = [
            Song(name: "Song 1", artist: "Artist 1", album: "Album 1", thumbnailUrl: "url1", previewUrl: "url1"),
            Song(name: "Song 2", artist: "Artist 2", album: "Album 2", thumbnailUrl: "url2", previewUrl: "url2")
        ]
        let sut = makeSUT(result: .success(expectedSongs))

        let expectationUpdate = expectation(description: "Songs should be updated")
        sut.onSongsUpdated = {
            XCTAssertEqual(sut.songs, expectedSongs)
            expectationUpdate.fulfill()
        }

        let expectationLoading = expectation(description: "Loading state should be updated")
        var loadingStates: [Bool] = []
        sut.onLoadingStateChanged = { isLoading in
            loadingStates.append(isLoading)
            if loadingStates.count == 2 {
                expectationLoading.fulfill()
            }
        }

        sut.searchSongs(term: "test")

        wait(for: [expectationUpdate, expectationLoading], timeout: 1.0)
        XCTAssertEqual(loadingStates, [true, false])
    }
    
    @MainActor
    func test_searchSongs_failure() {
        let error = URLError(.notConnectedToInternet)
        let sut = makeSUT(result: .failure(error))
        
        let expectationError = expectation(description: "Error should be handled")
        sut.onSongsSearchError = { message in
            XCTAssertEqual(message, "No internet connection. Please check your network settings.")
            expectationError.fulfill()
        }
        
        sut.searchSongs(term: "test")
        
        wait(for: [expectationError], timeout: 1.0)
        XCTAssertTrue(sut.songs.isEmpty)
    }
}
