//
//  ItunesSongAdapter.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 11/03/25.
//

import Foundation

struct ITunesSongResponse: Codable {
    let resultCount: Int
    let results: [ITunesSong]
}

struct ITunesSong: Codable {
    let trackName: String
    let artistName: String
    let collectionName: String?
    let artworkUrl100: String
    let previewUrl: String
}

final class ITunesSongAdapter: SongAdapter {
    typealias Response = ITunesSongResponse
    
    func adapt(response: Response) -> [Song] {
        return response.results.map { itunesSong in
            Song(
                name: itunesSong.trackName,
                artist: itunesSong.artistName,
                album: itunesSong.collectionName,
                thumbnailUrl: itunesSong.artworkUrl100,
                previewUrl: itunesSong.previewUrl
            )
        }
    }
}
