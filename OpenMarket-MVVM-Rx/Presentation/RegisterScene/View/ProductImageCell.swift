//
//  ProductImageCell.swift
//  OpenMarket-MVVM-Rx
//
//  Created by Hyoju Son on 2022/09/09.
//

import UIKit

final class ProductImageCell: UICollectionViewCell {
    // MARK: - Properties
    private let imageView = UIImageView()
    private(set) var editButton = UIButton()
    private(set) var removeButton = UIButton()
    private(set) var indexPath: IndexPath?
    
    // MARK: - Initializers
    convenience init() {
        self.init(frame: .zero)
        configureUI()
        setupButton()
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - Methods
    func setupProductImage(with image: UIImage?) {
        imageView.image = image
    }
    
    func updateIndexPath(at indexPath: Int) {
        self.indexPath?.row = indexPath
    }
    
    private func configureUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(editButton)
        contentView.addSubview(removeButton)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            editButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            removeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            removeButton.heightAnchor.constraint(equalToConstant: 26),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            removeButton.widthAnchor.constraint(equalToConstant: 26),
        ])
    }
    
    private func setupButton() {
        let image = UIImage(systemName: "minus.circle.fill")
        removeButton.setImage(image, for: .normal)
        removeButton.backgroundColor = .white
        removeButton.layer.cornerRadius = 13
        removeButton.tintColor = .systemRed
    }
}
