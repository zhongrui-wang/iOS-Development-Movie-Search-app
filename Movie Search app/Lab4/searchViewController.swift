//
//  searchViewController.swift
//  Lab4
//
//  Created by RUI WANG on 10/21/19.
//  Copyright © 2019 RUI WANG. All rights reserved.
//

import UIKit

var searchMovieData: [Movie] = []
var searchImageCache: [UIImage] = []

class searchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    var theImageCache: [UIImage] = []
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: "searchcell", for: indexPath)
        CollectionView.cellForItem(at: indexPath)
        let imageview:UIImageView=UIImageView(frame: CGRect(x: 0, y: 0, width: 125, height: 185))
        if searchImageCache.count > 0{
            let index = indexPath.section * 3 + indexPath.item
            if((index + 1)<=searchImageCache.count){
                imageview.image = searchImageCache[index]
                cell.contentView.addSubview(imageview)
            }
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.8
            blurView.frame = CGRect(x: 0, y: 155, width: 125, height: 30)
            let Label = UILabel(frame: CGRect(x: 0, y: 155, width: 125, height: 30))
            if searchMovieData.count > 0{
                if((index + 1)<=searchImageCache.count){
                    Label.text = searchMovieData[index].title
                }
                Label.textColor = UIColor.white
                Label.textAlignment = .center
                cell.contentView.addSubview(blurView)
                cell.contentView.addSubview(Label)
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.delegate = self
        setupCollectionView()
        spinner.hidesWhenStopped = true
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.spinner.startAnimating()
                self.CollectionView.reloadData()
                self.spinner.stopAnimating()
//                self.spinner.hidesWhenStopped = true
            }
        }
        navigationItem.title = "Search"
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        searchMovieData.removeAll()
        searchImageCache.removeAll()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.fetchDataFromSearch(searchText: searchText)
        self.cacheSearchImages()
        self.CollectionView.reloadData()
        searchBar.setShowsCancelButton(true, animated: true)
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataFromSearch(searchText: searchText)
            self.cacheSearchImages()
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.CollectionView.reloadData()
            }
        }
        spinner.stopAnimating()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchMovieData.removeAll()
        searchImageCache.removeAll()
        searchBar.text = nil
        CollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func setupCollectionView(){
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func fetchDataFromSearch(searchText:String){
        if searchText != ""{
            let replacedSearchText = searchText.replacingOccurrences(of: " ", with: "+")
            let url = URL(string: ("https://api.themoviedb.org/3/search/movie?api_key=a8c427154e7e40142144d3fb39e20a02&query="+replacedSearchText))
            let data = try! Data(contentsOf: url!)
            let json = try!JSONDecoder().decode(APIResults.self, from: data)
            for data in json.results {
                searchMovieData.append(data)
            }
        }
    }
    
    func cacheSearchImages(){
        for item in searchMovieData{
            let path = item.poster_path
            var wholePath:[String] = []
            if path != nil{
                wholePath.append("https://image.tmdb.org/t/p/w500" + path!)
            }
            for item in wholePath{
                let image_url = URL(string: item)
                let data = try?Data(contentsOf: image_url!)
                let image = UIImage(data: data!)
                searchImageCache.append(image!)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select item")
        let detailedVC = detailedViewController()
        let index = indexPath.section * 3 + indexPath.item
        if(searchMovieData.count != 0 ){
            if((index + 1)<=searchImageCache.count){
                detailedVC.index = index
                detailedVC.movie_id = searchMovieData[index].id
                detailedVC.image = searchImageCache[index]
                detailedVC.movie_title = searchMovieData[index].title
                detailedVC.overview = searchMovieData[index].overview
                detailedVC.release_date = searchMovieData[index].release_date
                detailedVC.vote_average = searchMovieData[index].vote_average
                navigationController?.pushViewController(detailedVC, animated: true)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
