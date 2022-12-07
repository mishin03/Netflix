//
//  HeroHeaderView.swift
//  Netflix
//
//  Created by Илья Мишин on 19.11.2022.
//

import UIKit

protocol HeroHeaderViewDelegate: AnyObject {
    func pressPlayButton(movie: TitleMovie)
}

class HeroHeaderView: UIView {
    
    let titleMovies = [TitleMovie]()
    
    var movie: TitleMovie?
    
    weak var delegate: HeroHeaderViewDelegate?
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(heroImageView)
        addGradient()
        addSubview(playButton)
        addSubview(downloadButton)
        applyConstraints()
        
        playButton.addTarget(self, action: #selector(pressPlayButton), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        playButton.addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
        
        downloadButton.addTarget(self, action: #selector(pressDownloadButton), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        downloadButton.addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pressPlayButton() {
        guard let movie else { return }
        delegate?.pressPlayButton(movie: movie)
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
    
    @objc func pressDownloadButton() {
        guard let movie else { return }
        DataPersistanceManager.shared.downloadMovieWith(model: movie) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
                print("Success Download")
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: topAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heroImageView.leftAnchor.constraint(equalTo: leftAnchor),
            heroImageView.rightAnchor.constraint(equalTo: rightAnchor),
            
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else { return }
        heroImageView.sd_setImage(with: url)
    }
}
