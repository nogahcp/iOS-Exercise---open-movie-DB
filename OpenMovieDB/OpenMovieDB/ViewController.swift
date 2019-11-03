//
//  ViewController.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.moviesTableView.delegate = self
        self.moviesTableView.dataSource = self
        self.moviesSearckBar.delegate = self
        
    }
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearckBar: UISearchBar!
    
    //model - fetch and contains the data
    var movieDBModel = MoviesDBModel()
    
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieDBModel.movies.count
    }
    
    //return cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.moviesTableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieTableViewCell
        
        let movie = self.movieDBModel.movies[indexPath.row]
        //set cell data
        if let url = movie.posterImage {
            self.downloadImage(from: url, into: cell)
        }
        cell.movieTitle?.text = movie.title
        cell.movieYear?.text = movie.year
        return cell
    }
    
    //return cell hight for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    //get image by url
    //from: https://stackoverflow.com/a/27712427
    func downloadImage(from url: URL, into cell: MovieTableViewCell) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                cell.movieImage.image = UIImage(data: data)
            }
        }
    }
    //Create a method with a completion handler to get the image data from your url
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}

