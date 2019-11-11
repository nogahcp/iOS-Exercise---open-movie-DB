//
//  ViewController.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MoviesDBModelDelegate {
    
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearckBar: UISearchBar!
    @IBOutlet weak var errorLabel: UILabel!
    
    //model - fetch and contains the data
    var movieDBModel = MoviesDataSource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moviesTableView.delegate = self
        self.moviesTableView.dataSource = self
        self.moviesSearckBar.delegate = self
        self.movieDBModel.delegate = self
    }
    
    /*
     table view
     */
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieDBModel.movies.count
    }
    
    //return cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //remove error if exist
        self.errorLabel.isHidden = true
        let cell = self.moviesTableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieTableViewCell
        guard indexPath.row < self.movieDBModel.movies.count else {
            return cell;
        }
        //fetch more movies when getting to the table end
        if indexPath.row == (self.movieDBModel.movies.count - 1) {
            self.movieDBModel.getMoreResults()
        }
        let movie = self.movieDBModel.movies[indexPath.row]
        //set cell data
        if let url = movie.posterImage {
            self.downloadImage(from: url, into: cell)
        }
        cell.movieTitle?.text = movie.title
        cell.movieYear?.text = movie.year
        cell.movieID = movie.imdbID
        return cell
    }
    
    //return cell hight for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100;
    }
    
    
    //get image by url into cell
    //from: https://stackoverflow.com/a/27712427
    func downloadImage(from url: URL, into cell: MovieTableViewCell) {
        //if exist old image remove it, and add spining wheel
        cell.movieImage.image = nil
        cell.imageSpiningWheel.isHidden = false
        cell.imageSpiningWheel.startAnimating()
        print("Download Started")
        url.getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                //if download image did not succeed - put placeholder
                DispatchQueue.main.async() {
                    cell.movieImage.image = UIImage(named: "imagePlaceHolder")
                    //remove spining wheel
                    cell.imageSpiningWheel.stopAnimating()
                    cell.imageSpiningWheel.isHidden = true
                }
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                cell.movieImage.image = UIImage(data: data)
                //remove spining wheel
                cell.imageSpiningWheel.stopAnimating()
                cell.imageSpiningWheel.isHidden = true
            }
        }
    }
    
    /*
     search bar
     */
    //when search insert - reload movies
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //search only for 2 letters or more
        if searchText.count > 1 {
            self.movieDBModel.searchMovies(for: searchText)
        }
        //if search is clean, clean results
        if searchText.count == 0 {
            self.errorLabel.text = ""
            self.movieDBModel.searchMovies(for: "")
        }
    }

    /*
     segue to movie details page
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //get selected movie name
        if let movieCell = sender as! MovieTableViewCell? {
            if let movieName = movieCell.movieTitle.text {
                if let destinationVC = segue.destination as? MovieDetailsViewController {
                    destinationVC.title = movieName
                    let id = self.movieDBModel.movies.filter({
                        $0.imdbID == movieCell.movieID
                    })[0].imdbID
                    destinationVC.movieDetailsModel = MovieDetailsSource(id)                    
                }
            }
        }
    }
    
    //movieDBModel delegate method - update movies table when list in model is changed
    func moviesDidChange() {
        DispatchQueue.main.async {
            self.moviesTableView.reloadData()
        }
    }
    
    //movieDBModel delegate method - show error to user
    func handleError(error: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = error
            self.errorLabel.isHidden = false
        }
    }
}

extension URL {
    //from: https://stackoverflow.com/a/27712427 Create a method with a completion handler to get the image data from url
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
