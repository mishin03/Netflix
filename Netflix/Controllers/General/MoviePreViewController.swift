//
//  MoviePreViewController.swift
//  Netflix
//
//  Created by Илья Мишин on 23.11.2022.
//

import UIKit
import WebKit

protocol Movie {
    var original_name: String? { get }
    var original_title: String? { get }
    var overview: String? { get }
}

extension TitleMovie: Movie {}
extension MovieItem: Movie {}

class MoviePreViewController: UIViewController {
    
    var movie: Movie?
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 7
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(downloadButton)

        applyConstraints()
        setupStrings()
        loadDetails()
        
        downloadButton.addTarget(self, action: #selector(pressDownloadButton), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        downloadButton.addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
}

private extension MoviePreViewController {
    
    @objc func pressDownloadButton() {
        DataPersistanceManager.shared.downloadMovieWith(model: movie as! TitleMovie) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
                print("Success Download")
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
            button.transform = transform
        }, completion: nil)
    }

    func applyConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            downloadButton.widthAnchor.constraint(equalToConstant: 140),
            downloadButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupStrings() {
        guard let movie else { return }

        titleLabel.text = movie.original_title ?? movie.original_name
        overviewLabel.text = movie.overview
    }

    func loadDetails() {
        guard let movieName = movie?.original_title ??
                movie?.original_name else { return }

        APICaller.shared.youtubeSearch(with: movieName + " trailer") { [weak self] results in
            switch results {
                case .success(let response):
                    guard let self else { return }
                    guard let url = URL(string: "https://www.youtube.com/embed/\(response.id.videoId)") else { return }
                DispatchQueue.main.async {
                    self.webView.load(URLRequest(url: url))
                }
                case .failure(let failure):
                    print(failure)
            }
        }
    }
}
