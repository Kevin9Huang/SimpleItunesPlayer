//
//  SimplePlayerView.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 12/03/25.
//

import UIKit
import AVFoundation

protocol SimplePlayerViewDelegate: AnyObject {
    func didTapPlayPause()
    func didTapPrevious()
    func didTapNext()
    func didChangePlaybackPosition(to value: Float)
}

final class SimplePlayerView: UIView {
    weak var delegate: SimplePlayerViewDelegate?
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let songTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        backgroundColor = .systemGray5
        
        addSubview(previousButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        addSubview(songTitleLabel)
        addSubview(progressSlider)
        
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            songTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            songTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            songTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressSlider.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    @objc private func playPauseButtonTapped() {
        delegate?.didTapPlayPause()
    }
    
    @objc private func previousButtonTapped() {
        delegate?.didTapPrevious()
    }
    
    @objc private func nextButtonTapped() {
        delegate?.didTapNext()
    }
    
    @objc private func sliderValueChanged() {
        delegate?.didChangePlaybackPosition(to: progressSlider.value)
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func updateSongTitle(_ title: String) {
        songTitleLabel.text = title
    }
    
    func updateProgress(value: Float) {
        progressSlider.value = value
    }
}
