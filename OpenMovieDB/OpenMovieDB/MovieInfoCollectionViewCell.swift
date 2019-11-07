//
//  MovieInfoCollectionViewCell.swift
//  OpenMovieDB
//
//  Created by  temp on 04/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class MovieInfoCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // designe cell
        self.infoLabel.numberOfLines = 3
        
    }
    
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    

}
