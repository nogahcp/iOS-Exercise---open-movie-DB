//
//  MovieInfoCollectionViewCell.swift
//  OpenMovieDB
//
//  Created by  temp on 04/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class MovieInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // designe cell
        self.infoLabel.numberOfLines = 3
        self.setCellView()
    }
    
    private func setCellView() {
        //set rounded corners
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = false
        //set shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2.0
    }

}
