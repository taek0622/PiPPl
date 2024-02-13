//
//  LocalVideoThumbnailCell.swift
//  PiPPl
//
//  Created by 김민택 on 1/17/24.
//

import UIKit

class LocalVideoThumbnailCell: UICollectionViewCell {

    // MARK: - Property

    static let identifier = "LocalVideoThumbnailCell"

    // MARK: - View

    private let imageView: UIImageView = {
        $0.image = UIImage(ciImage: CIImage(color: .gray))
        $0.contentMode = .scaleToFill
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())

    private let playTimeLabel: UILabel = {
        $0.text = ""
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Method

    private func layout() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        imageView.addSubview(playTimeLabel)
        NSLayoutConstraint.activate([
            playTimeLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -4),
            playTimeLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -4)
        ])
    }

    func configureThumbnail(_ image: UIImage) {
        imageView.image = image
    }

    func configureVideoPlayTime(_ duration: TimeInterval) {
        let duration = Int(duration)
        playTimeLabel.text = "\(duration / 60):\(String(format: "%02d", duration % 60))"
    }
}
