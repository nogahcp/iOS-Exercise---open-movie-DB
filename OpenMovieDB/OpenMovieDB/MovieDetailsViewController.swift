//
//  MovieDetailsViewController.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MoviesDBModelDelegate {

    var movieDBModel = MoviesDBModel()
    
    @IBOutlet weak var movieInfoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //get movie details from model
        self.movieInfoCollectionView.delegate = self
        self.movieInfoCollectionView.dataSource = self
        self.movieDBModel.delegate = self
    }
    
    //get number of cells from model
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieDBModel.details.count
    }
    
    //create cell and return
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get param name from model
        let currParam = self.movieDBModel.paramsOrder[indexPath.row]
        //if poster - create an Image cell
        if currParam == "Poster" {
            return self.createPosterCell(at: indexPath)
        }
        let cell = self.movieInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "movieDetailCell", for: indexPath) as! MovieInfoCollectionViewCell
        //get param info
        cell.paramLabel.text = currParam
        guard let currInfo = self.movieDBModel.details[currParam] as? String
            else {
                return cell
            }
        cell.infoLabel.text = currInfo
        return cell
    }
    
    private func createPosterCell(at index: IndexPath) -> UICollectionViewCell {
        let cell = self.movieInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: index) as! ImageCollectionViewCell
        let param = self.movieDBModel.paramsOrder[index.row]
        if let url = self.movieDBModel.details[param] {
            self.downloadImage(from: URL(string: url as! String)!, into: cell)
        }
        return cell
    }
    
    func movieDetailsUpdate() {
        DispatchQueue.main.async() {
            self.movieInfoCollectionView.reloadData()
        }
    }
    
    //get image by url into cell
    //from: https://stackoverflow.com/a/27712427
    private func downloadImage(from url: URL, into cell: ImageCollectionViewCell) {
        //if exist old image remove it, and add spining wheel
        cell.imageView.image = nil
        cell.spinningWheel.startAnimating()
        print("Download Started")
        url.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                cell.imageView.image = UIImage(data: data)
                //remove spining wheel
                cell.spinningWheel.stopAnimating()
                cell.spinningWheel.isHidden = true
            }
        }
    }

}
