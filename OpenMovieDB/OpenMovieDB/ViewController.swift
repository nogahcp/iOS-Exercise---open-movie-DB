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
    
    //model - fetch and contains the data
    var movieDBModel = MoviesDBModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moviesTableView.delegate = self
        self.moviesTableView.dataSource = self
        self.moviesSearckBar.delegate = self
        self.movieDBModel.delegate = self
    }

    
//    var movies = MoviesDBModel().movies {
//        didSet {
//            self.moviesTableView.reloadData()
//        }
//    }
    
    /*
     table view
     */
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieDBModel.movies.count
    }
    
    //return cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        return cell
    }
    
    //return cell hight for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //TODO: change!!
        return 100;
    }
    
    //when row is selected - ask model to fetch data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movieDBModel.fetchMovieData(at: indexPath.row)
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
    
    /*
     search bar
     */
    //when search insert - reload movies
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //search only for 2 letters or more
        if searchText.count > 1 {
            self.movieDBModel.searchMovies(for: searchText)
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
                    destinationVC.movieDBModel = self.movieDBModel
                }
            }
        }
    }
    
    //movieDBModel delegate method - update movies table when list in model is changed
    func moviesDidChange() {
        DispatchQueue.main.async {
            self.moviesTableView.reloadData()
    }    }
}

