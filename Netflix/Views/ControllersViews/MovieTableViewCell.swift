//
//  TitleTableViewCell.swift
//  Netflix
//
//  Created by Илья Мишин on 23.11.2022.
//

import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {
    
    static let identifier = "TitleTableViewCell"
    
    let upcomingPosterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(upcomingPosterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            upcomingPosterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upcomingPosterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            upcomingPosterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            upcomingPosterImageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: upcomingPosterImageView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else { return }
        upcomingPosterImageView.sd_setImage(with: url)
        titleLabel.text = model.titleName
    }
}
