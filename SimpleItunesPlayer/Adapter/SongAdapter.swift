//
//  SongAdapter.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 11/03/25.
//

import Foundation

protocol SongAdapter {
    associatedtype Response
    func adapt(response: Response) -> [Song]
}
