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
        //get image using Kingfisher
        cell.imageView.kf.indicatorType = .activity
        if let url = self.movieDetailsModel.details[param] {
            cell.imageView.kf.setImage(
                with: URL(string: (url as! String)),
                placeholder: UIImage(named: "imagePlaceHolder"),
                options: [
                ])
        }
        //if no url set placeholder (details[param] is nil)
        else {
            cell.imageView.image = UIImage(named: "imagePlaceHolder")
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
    
    
    //MovieDetailsModelDelegate got error - inform user
    func handleError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
