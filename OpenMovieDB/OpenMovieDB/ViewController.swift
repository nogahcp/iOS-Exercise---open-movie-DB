//
//  ViewController.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MoviesDBModelDelegate {
    
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearckBar: UISearchBar!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    //model - fetch and contains the data
    var movieDBModel = MoviesDataSource()
    //images cache
    var imagesCache = NSCache<NSString, UIImage>()
    
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
        self.setImage(for: movie, into: cell)

        cell.movieTitle?.text = movie.title
        cell.movieYear?.text = movie.year
        cell.movieID = movie.imdbID
        return cell
    }
    
    //return cell hight for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100;
    }
    
    //set image into cell
    private func setImage(for movie: Movie, into cell: MovieTableViewCell) {
        //if exist old image remove it
        cell.movieImage.image = nil
        //get image using Kingfisher
        cell.movieImage.kf.indicatorType = .activity
        cell.movieImage.kf.setImage(
            with: movie.posterImage,
            placeholder: UIImage(named: "imagePlaceHolder"),
            options: [
            ])
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
            self.movieDBModel.searchMovies(for: "")
            self.errorLabel.text = ""
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
            //show error on screen. if no search - hide error
            self.errorLabel.text = error
            self.errorLabel.isHidden = self.moviesSearchBar.text?.count == 0 ? true : false
        }
    }
}
