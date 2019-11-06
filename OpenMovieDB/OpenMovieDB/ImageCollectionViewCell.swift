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
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
    
}
