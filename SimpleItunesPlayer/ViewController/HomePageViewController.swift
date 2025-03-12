//
//  HomePageViewController.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 10/03/25.
//

import UIKit
import AVFoundation

final class HomePageViewController: UIViewController {
    private var timeObserverToken: Any?
    private var viewModel: HomePageViewModel<ITunesSongAdapter>!
    private var player: AVPlayer?
    private var currentSongIndex: Int = -1
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search for songs..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playerView: SimplePlayerView = {
        let playerView = SimplePlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupTableView()
        setupPlayerView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorView)
        view.addSubview(playerView)
        errorView.addSubview(errorImageView)
        errorView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            searchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.widthAnchor.constraint(equalToConstant: 80),
            searchButton.heightAnchor.constraint(equalTo: searchTextField.heightAnchor),
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: playerView.topAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: playerView.topAnchor),
            errorImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorImageView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            errorImageView.widthAnchor.constraint(equalToConstant: 60),
            errorImageView.heightAnchor.constraint(equalToConstant: 60),
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupViewModel() {
        let songsFetcherService = SongsFetcherService()
        let iTunesAdapter = ITunesSongAdapter()
        viewModel = HomePageViewModel(songsFetcherService: songsFetcherService, adapter: iTunesAdapter)
        
        viewModel.onSongsUpdated = { [weak self] in
            self?.tableView.isHidden = false
            self?.errorView.isHidden = true
            self?.tableView.reloadData()
        }
        
        viewModel.onSongsSearchError = { [weak self] errorMessage in
            self?.tableView.isHidden = true
            self?.errorView.isHidden = false
            self?.errorLabel.text = errorMessage
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongTableViewCell.self, forCellReuseIdentifier: "SongTableViewCell")
    }
    
    private func setupPlayerView() {
        playerView.delegate = self
    }
    
    @objc private func searchButtonTapped() {
        guard let searchTerm = searchTextField.text, !searchTerm.isEmpty else { return }
        viewModel.searchSongs(term: searchTerm)
    }
    
    private func playSong(at index: Int) {
        guard index >= 0, index < viewModel.songs.count else { return }
        
        self.cleanUpPreviousSong()
        if let url = URL(string: viewModel.songs[index].previewUrl) {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            currentSongIndex = index
            playerView.updatePlayPauseButton(isPlaying: true)
            playerView.updateSongTitle(viewModel.songs[index].name)
            updateTableViewSelection()
            
            observePlayerProgress()
        }
    }
    
    private func cleanUpPreviousSong() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        removePlayerProgressObserver()
    }
    
    private func observePlayerProgress() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration.seconds, duration.isFinite else { return }
            let progress = Float(time.seconds / duration)
            self.playerView.updateProgress(value: progress)
        }
    }
    
    private func removePlayerProgressObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func updateTableViewSelection() {
        tableView.selectRow(at: IndexPath(row: currentSongIndex, section: 0), animated: true, scrollPosition: .none)
    }
}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        let song = viewModel.songs[indexPath.row]
        cell.configure(with: song)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playSong(at: indexPath.row)
    }
}

extension HomePageViewController: SimplePlayerViewDelegate {
    func didTapPlayPause() {
        if player?.rate == 0 {
            player?.play()
            playerView.updatePlayPauseButton(isPlaying: true)
        } else {
            player?.pause()
            playerView.updatePlayPauseButton(isPlaying: false)
        }
    }
    
    func didTapPrevious() {
        guard currentSongIndex > 0 else { return }
        playSong(at: currentSongIndex - 1)
    }
    
    func didTapNext() {
        if currentSongIndex == -1 {
            playSong(at: 0)
        } else if currentSongIndex < viewModel.songs.count - 1 {
            playSong(at: currentSongIndex + 1)
        }
    }
    
    func didChangePlaybackPosition(to value: Float) {
        guard let duration = player?.currentItem?.duration.seconds, duration.isFinite else { return }
        let newTime = CMTime(seconds: Double(value) * duration, preferredTimescale: 600)
        player?.seek(to: newTime)
    }
}
