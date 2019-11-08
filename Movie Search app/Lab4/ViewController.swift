//
//  ViewController.swift
//  Lab4
//
//  Created by RUI WANG on 10/9/19.
//  Copyright © 2019 RUI WANG. All rights reserved.
//

import UIKit

struct APIResults:Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}


struct Movie: Decodable {
    let id: Int!
    let poster_path: String?
    let title: String?
    let release_date: String?
    let vote_average: Double
    let overview: String
    let vote_count:Int!
}

var currentMovieData: [Movie] = []
var currentImageCache: [UIImage] = []

var favorite: [String] = []
let defaults = UserDefaults.standard

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{
    
    var movieData: [Movie] = []
    var theImageCache: [UIImage] = []
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int((Float(theImageCache.count)/3).rounded())
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath)
        CollectionView.cellForItem(at: indexPath)
        if currentImageCache.count > 0{
            let imageview:UIImageView=UIImageView(frame: CGRect(x: 0, y: 0, width: 125, height: 185))
            let index = indexPath.section * 3 + indexPath.item
            if((index + 1)<=currentImageCache.count){
                imageview.image = currentImageCache[index]
                cell.contentView.addSubview(imageview)
            }
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.8
            blurView.frame = CGRect(x: 0, y: 155, width: 125, height: 30)
            let Label = UILabel(frame: CGRect(x: 0, y: 155, width: 125, height: 30))
            if currentMovieData.count > 0{
                if((index + 1)<=currentImageCache.count){
                    Label.text = currentMovieData[index].title
                }
                Label.textColor = UIColor.white
                Label.textAlignment = .center
                cell.contentView.addSubview(blurView)
                cell.contentView.addSubview(Label)
            }
        }
        return cell
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
   
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.spinner.hidesWhenStopped = true
        searchBar.delegate = self
        setupCollectionView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataForCollectionView()
            self.cacheImages()
            DispatchQueue.main.async {
                self.spinner.startAnimating()
                self.CollectionView.reloadData()
                self.spinner.stopAnimating()
            }
        }
        navigationItem.title = "Popular Movies"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        currentMovieData.removeAll()
        currentImageCache.removeAll()
//        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        searchBar.setShowsCancelButton(true, animated: true)
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataFromSearch(searchText: searchText)
            self.cacheSearchImages()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.spinner.stopAnimating()
                self.CollectionView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentMovieData = movieData
        currentImageCache = theImageCache
        searchBar.text = nil
        CollectionView.reloadData()
//        CollectionView.removeFromSuperview()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func setupCollectionView(){
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func fetchDataForCollectionView(){ //searchTerm: String?
        currentMovieData.removeAll()
        currentImageCache.removeAll()
        let url = URL(string: ("https://api.themoviedb.org/3/movie/popular?api_key=a8c427154e7e40142144d3fb39e20a02&language=en-US&page=1"))
        let data = try! Data(contentsOf: url!)
        let json = try!JSONDecoder().decode(APIResults.self, from: data)
        for data in json.results {
            movieData.append(data)
        }
        currentMovieData = movieData
        print("The data is \(data)")
        print("Json is \(json)")
        print("movie data is \(movieData)")
    }
    
    func cacheImages(){
        for item in movieData{
            let path = item.poster_path
            var wholePath:[String] = []
            if path != nil{
                wholePath.append("https://image.tmdb.org/t/p/w500" + path!)
            }
            for item in wholePath{
                let image_url = URL(string: item)
                let data = try?Data(contentsOf: image_url!)
                let image = UIImage(data: data!)
                theImageCache.append(image!)
            }
        }
        currentImageCache = theImageCache
    }
    
    func fetchDataFromSearch(searchText:String){
        if searchText != ""{
            let replacedSearchText = searchText.replacingOccurrences(of: " ", with: "+")
            let url = URL(string: ("https://api.themoviedb.org/3/search/movie?api_key=a8c427154e7e40142144d3fb39e20a02&query="+replacedSearchText))
            let data = try! Data(contentsOf: url!)
            let json = try!JSONDecoder().decode(APIResults.self, from: data)
            for data in json.results {
                currentMovieData.append(data)
            }
        }
    }
    
    func cacheSearchImages(){
        for item in currentMovieData{
            let path = item.poster_path
            var wholePath:[String] = []
            if path != nil{
                wholePath.append("https://image.tmdb.org/t/p/w500" + path!)
            }
            for item in wholePath{
                let image_url = URL(string: item)
                let data = try?Data(contentsOf: image_url!)
                let image = UIImage(data: data!)
                currentImageCache.append(image!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select item")
        let detailedVC = detailedViewController()
        let index = indexPath.section * 3 + indexPath.item
        if((index + 1)<=currentImageCache.count){
            detailedVC.index = index
            detailedVC.movie_id = currentMovieData[index].id
            detailedVC.image = currentImageCache[index]
            detailedVC.movie_title = currentMovieData[index].title
            detailedVC.overview = currentMovieData[index].overview
            detailedVC.release_date = currentMovieData[index].release_date
            detailedVC.vote_average = currentMovieData[index].vote_average
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }

}

