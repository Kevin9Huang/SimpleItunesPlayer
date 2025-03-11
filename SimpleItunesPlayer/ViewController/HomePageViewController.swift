//
//  HomePageViewController.swift
//  SimpleItunesPlayer
//
//  Created by CMP2024008 on 10/03/25.
//

import UIKit

final class HomePageViewController: UIViewController {
    
    private var viewModel: HomePageViewModel<ITunesSongAdapter>!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupViewModel() {
        let songsFetcherService = SongsFetcherService()
        let iTunesAdapter = ITunesSongAdapter()
        viewModel = HomePageViewModel(songsFetcherService: songsFetcherService, adapter: iTunesAdapter)
        
        viewModel.onSongsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongTableViewCell.self, forCellReuseIdentifier: "SongTableViewCell")
    }
    
    @objc private func searchButtonTapped() {
        guard let searchTerm = searchTextField.text, !searchTerm.isEmpty else { return }
        viewModel.searchSongs(term: searchTerm)
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
}

