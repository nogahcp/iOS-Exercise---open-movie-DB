//
//  ImageCollectionViewCell.swift
//  OpenMovieDB
//
//  Created by  temp on 06/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // designe cell
        self.updateImageView()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
    
    private func updateImageView() {

//        self.frame.size = CGSize(width: 90, height: 90)
        self.layer.cornerRadius = 8
        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true
    }
}
