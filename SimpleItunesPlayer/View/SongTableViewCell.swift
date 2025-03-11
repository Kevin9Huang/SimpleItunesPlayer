//
//  SongTableViewCell.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 11/03/25.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Add subviews
        contentView.addSubview(artworkImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(albumNameLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Artwork Image View
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artworkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artworkImageView.widthAnchor.constraint(equalToConstant: 50),
            artworkImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Track Name Label
            trackNameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 16),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Artist Name Label
            artistNameLabel.leadingAnchor.constraint(equalTo: trackNameLabel.leadingAnchor),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.trailingAnchor.constraint(equalTo: trackNameLabel.trailingAnchor),
            
            // Album Name Label
            albumNameLabel.leadingAnchor.constraint(equalTo: trackNameLabel.leadingAnchor),
            albumNameLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 4),
            albumNameLabel.trailingAnchor.constraint(equalTo: trackNameLabel.trailingAnchor),
            albumNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with song: Song) {
        trackNameLabel.text = song.name
        artistNameLabel.text = song.artist
        albumNameLabel.text = song.album
        
        // Load thumbnail image asynchronously
        if let url = URL(string: song.thumbnailUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.artworkImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
