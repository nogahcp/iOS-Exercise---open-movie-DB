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
        //oself.updateCellHeight()
    }
    
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    func updateCellHeight() {
        //get labels hight
//        let infoHieght = infoLabel.numberOfLines * self.infoLabel.font.pointSize
//        let paramHight = paramLabel.frame.height
        //change cell height
//        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width:self.frame.width, height: infoHieght + paramHight+20)
        

    }
    
}
