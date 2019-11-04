//
//  MovieDetailsViewController.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var movieDBModel = MoviesDBModel()

    @IBOutlet weak var movieInfoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //get movie details from model
        self.movieInfoCollectionView.delegate = self
        self.movieInfoCollectionView.dataSource = self
    }
    
    //get number of cells from model
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieDBModel.details.count
    }
    
    //create cell and return
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.movieInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "movieDetailCell", for: indexPath) as! MovieInfoCollectionViewCell
        //get param and info
        let currParam = Array(self.movieDBModel.details.keys)[indexPath.row]
        cell.paramLabel.text = currParam
        
        guard let currInfo = self.movieDBModel.details[currParam] as? String
            else {
                return cell
                }
        cell.infoLabel.text = currInfo
        return cell
    }

}
