//
//  SongsFetcherServiceTests.swift
//  SimpleItunesPlayerTests
//
//  Created by CMP2024008 on 12/03/25.
//

import XCTest
@testable import SimpleItunesPlayer

final class SongsFetcherServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    private func makeSut(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SongsFetcherService, mockNetworkService: MockNetworkService, mockAdapter: MockSongAdapter){
        let mockNetworkService = MockNetworkService()
        let mockAdapter = MockSongAdapter()
        let sut = SongsFetcherService(networkService: mockNetworkService)
        trackForMemoryLeaks(sut, file: file, line:line)
        return (sut, mockNetworkService, mockAdapter)
    }
    
    func test_fetchSongs_Success() {
        let (sut, mockNetworkService, mockAdapter) = makeSut()
        let expectedSongs = [
            Song(name: "Song 1", artist: "Artist 1", album: "Album 1", thumbnailUrl: "url1", previewUrl: "preview1"),
            Song(name: "Song 2", artist: "Artist 2", album: "Album 2", thumbnailUrl: "url2", previewUrl: "preview2")
        ]
        
        let mockResponse = MockAPIResponse() // Simulating a decodable response
        mockNetworkService.result = .success(mockResponse)
        mockAdapter.songsToReturn = expectedSongs
        
        let expectation = self.expectation(description: "fetchSongs completion should be called")
        
        sut.fetchSongs(searchTerm: "test", adapter: mockAdapter) { result in
            switch result {
            case .success(let songs):
                XCTAssertEqual(songs, expectedSongs)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_fetchSongs_Failure() {
        let (sut, mockNetworkService, mockAdapter) = makeSut()
        mockNetworkService.result = .failure(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        let expectation = self.expectation(description: "fetchSongs completion should be called")
        
        sut.fetchSongs(searchTerm: "test", adapter: mockAdapter) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

class MockNetworkService: NetworkService {
    var result: Result<MockAPIResponse, Error>?
    
    func request<T>(_ endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        if let result = result as? Result<T, Error> {
            completion(result)
        }
    }
}

struct MockAPIResponse: Decodable {
    let mockData: String = "Test"
}

class MockSongAdapter: SongAdapter {
    typealias Response = MockAPIResponse
    var songsToReturn: [Song] = []
    
    func adapt(response: MockAPIResponse) -> [Song] {
        return songsToReturn
    }
}

extension Song: Equatable {
    public static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.name == rhs.name &&
               lhs.artist == rhs.artist &&
               lhs.album == rhs.album &&
               lhs.thumbnailUrl == rhs.thumbnailUrl &&
               lhs.previewUrl == rhs.previewUrl
    }
}
