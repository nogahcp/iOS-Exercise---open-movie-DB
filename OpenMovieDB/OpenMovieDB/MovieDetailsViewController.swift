//
//  MovieDetailsViewController.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MovieDetailsModelDelegate {

    var movieDetailsModel = MovieDetailsSource()
    
    @IBOutlet weak var movieInfoCollectionView: UICollectionView!
    @IBOutlet weak var detailsSpinningWheel: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //get movie details from model
        self.movieInfoCollectionView.delegate = self
        self.movieInfoCollectionView.dataSource = self
        self.movieDetailsModel.delegate = self
        detailsSpinningWheel.isHidden = false
    }
    
    //get number of cells from model
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieDetailsModel.details.count
    }
    
    //create cell and return
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get param name from model
        let currParam = self.movieDetailsModel.paramsOrder[indexPath.row]
        //if poster - create an Image cell
        if currParam == "Poster" {
            return self.dequeueImageCell(at: indexPath)
        }
        let cell = self.movieInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "movieDetailCell", for: indexPath) as! MovieInfoCollectionViewCell
        //get param info
        cell.paramLabel.text = currParam
        if let curInfo = self.movieDetailsModel.details[currParam] as? String {
            cell.infoLabel.text = curInfo
        }
        //add tap gesture
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        return cell
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        //get cell
        let location = sender.location(in: self.movieInfoCollectionView)
        let indexPath = self.movieInfoCollectionView.indexPathForItem(at: location)
        let cell = self.movieInfoCollectionView.cellForItem(at: indexPath!) as? MovieInfoCollectionViewCell
        //show alert with cell info
        let alert = UIAlertController(title: cell?.paramLabel.text, message: cell?.infoLabel.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func dequeueImageCell(at index: IndexPath) -> UICollectionViewCell {
        let cell = self.movieInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: index) as! ImageCollectionViewCell
        let param = self.movieDetailsModel.paramsOrder[index.row]
        if let url = self.movieDetailsModel.details[param] {
            self.downloadImage(from: URL(string: url as! String)!, into: cell)
        }
        //if no image url - put placeholder
        else {
            self.putPlaceHolderInCell(cell: cell)
        }
        return cell
    }
    
    func movieDetailsUpdate() {
        DispatchQueue.main.async() {
            self.movieInfoCollectionView.reloadData()
            //when movie details retrieve - hide spinning wheel
            self.detailsSpinningWheel.isHidden = true
        }
    }
    
    //get image by url into cell
    //from: https://stackoverflow.com/a/27712427
    private func downloadImage(from url: URL, into cell: ImageCollectionViewCell) {
        //if exist old image remove it, and add spining wheel
        cell.imageView.image = nil
        cell.spinningWheel.isHidden = false
        cell.spinningWheel.startAnimating()
        print("Download Started")
        url.getData(from: url) { data, response, error in
            //if download did not succeed - put placeholder
            guard let data = data, error == nil else {
                self.putPlaceHolderInCell(cell: cell)
                return
            }
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

    private func putPlaceHolderInCell(cell: ImageCollectionViewCell) {
        //if download image did not succeed - put placeholder
        DispatchQueue.main.async() {
            cell.imageView.image = UIImage(named: "imagePlaceHolder")
            //remove spining wheel
            cell.spinningWheel.stopAnimating()
            cell.spinningWheel.isHidden = true
        }
    }
    
    //MovieDetailsModelDelegate got error - inform user
    func handleError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
