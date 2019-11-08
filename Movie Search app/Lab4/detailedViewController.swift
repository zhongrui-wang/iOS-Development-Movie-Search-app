//
//  detailedViewController.swift
//  Lab4
//
//  Created by RUI WANG on 10/12/19.
//  Copyright © 2019 RUI WANG. All rights reserved.
//

import UIKit

struct trailerAPIResults:Decodable {
    let id: Int
    let results: [trailer]
}
struct trailer: Decodable{
    let id: String
    let iso_639_1: String
    let iso_3166_1: String
    let key: String
    let name: String
    let site: String
    let size: Int
    let type: String
}
struct externalID: Decodable{
    let id: Int
    let imdb_id: String?
    let facebook_id: String?
    let instagram_id: String?
    let twitter_id: String?
}

class detailedViewController: UIViewController {
    var image : UIImage!
    var movie_id : Int!
    var movie_title : String!
    var release_date: String!
    var vote_average: Double!
    var overview: String!
    var index: Int!
    var trailerData:[trailer] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        setupImageView()
        setupTitleView()
        setupVoteView()
        setupOverview()
        setupFavoriteButton()
        setupTrailerButton()
        setupTwitterButton()
    }
    
    func setupImageView(){
        let imageFrame = CGRect(x: view.frame.midX - image.size.width/4, y: 120, width: image.size.width/2, height: image.size.height/2)
        let imageView = UIImageView(frame: imageFrame)
        imageView.image = image
        view.addSubview(imageView)
    }
    
    func setupTitleView(){
        let titleFrame = CGRect(x: 0, y: 130 + image.size.height/2, width: view.frame.width, height: 30)
        let titleView = UILabel(frame: titleFrame)
        titleView.textAlignment = .center
        titleView.text = movie_title
        titleView.textColor = UIColor.black
        view.addSubview(titleView)
    }
    
    func setupVoteView(){
        let voteFrame = CGRect(x: 0, y: 155 + image.size.height/2, width: view.frame.width, height: 30)
        let voteView = UILabel(frame: voteFrame)
        voteView.text = "Average vote: \(String(vote_average))"
        voteView.textAlignment = .center
        view.addSubview(voteView)
    }
    
    func setupOverview(){
        let overviewFrame = CGRect(x: 40, y: 140 + image.size.height/2, width: 350, height: 200)
        let overview_View = UILabel(frame: overviewFrame)
        overview_View.text = overview
        overview_View.numberOfLines = Int(CGFloat(5))
        overview_View.textAlignment = .center
        view.addSubview(overview_View)
    }
    
    func setupFavoriteButton(){
        let buttonFrame =  CGRect(x: 107, y: 300 + image.size.height/2, width: 200, height: 30)
        let button  = UIButton(frame: buttonFrame)
        button.setTitle("Add to favorites", for:.normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(addFavorities), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func setupTrailerButton(){
        let secondButtonFrame =  CGRect(x: 107, y: 340 + image.size.height/2, width: 200, height: 30)
        let secondButton  = UIButton(frame: secondButtonFrame)
        secondButton.setTitle("Watch Trailer", for:.normal)
        secondButton.setTitleColor(UIColor.blue, for: .normal)
        secondButton.layer.borderColor = UIColor.blue.cgColor
        secondButton.layer.borderWidth = 1
        secondButton.layer.cornerRadius = 5
        secondButton.addTarget(self, action: #selector(openTrailer), for: .touchUpInside)
        view.addSubview(secondButton)
    }
    
    func setupTwitterButton(){
        let thirdButtonFrame =  CGRect(x: 107, y: 380 + image.size.height/2, width: 200, height: 30)
        let thirdButton  = UIButton(frame: thirdButtonFrame)
        thirdButton.setTitle("On Twitter", for:.normal)
        thirdButton.setTitleColor(UIColor.blue, for: .normal)
        thirdButton.layer.borderColor = UIColor.blue.cgColor
        thirdButton.layer.borderWidth = 1
        thirdButton.layer.cornerRadius = 5
        thirdButton.addTarget(self, action: #selector(inTwitter), for: .touchUpInside)
        view.addSubview(thirdButton)
    }
    
    @objc func addFavorities(sender: UIButton!){
        let defaults = UserDefaults.standard
//        favoriteMovieTitle.append(movie_title)
//        defaults.set(movie_title,forKey: "movieNameKey")
//        let nullcase:[String] = []
//        defaults.set(nullcase, forKey: "movieNameKey")
        var movie:[String] = []
        let names = defaults.array(forKey: "movieNameKey")
        if names != nil{
            for item in names!{
                movie.append(item as! String)
            }
            movie.append(movie_title)
            defaults.set(movie, forKey: "movieNameKey")
        }
        else{
            movie.append(movie_title)
            defaults.set(movie, forKey: "movieNameKey")
        }
        print("favorite is \(movie)")
    }
    
     @objc func openTrailer(sender: UIButton!){
        let movieID = String(movie_id) // Your movie ID here
        let url = URL(string: ("https://api.themoviedb.org/3/movie/" + movieID + "/videos?api_key=a8c427154e7e40142144d3fb39e20a02&language=en-US"))
        let data = try! Data(contentsOf: url!)
        let json = try!JSONDecoder().decode(trailerAPIResults.self, from: data)
        for data in json.results {
            trailerData.append(data)
        }
        if trailerData.count != 0{
            let youtubeID = trailerData[0].key
            let appURL = NSURL(string: "youtube://www.youtube.com/watch?v=\(youtubeID)")!
            let webURL = NSURL(string: "https://www.youtube.com/watch?v=\(youtubeID)")!
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                // if Youtube app is not installed, open URL inside Safari
                application.open(webURL as URL)
            }
        }
    }
    
    @objc func inTwitter(sender: UIButton!){
        let movieID = String(movie_id) // Your movie ID here
        let url = URL(string: ("https://api.themoviedb.org/3/movie/" + movieID + "/external_ids?api_key=a8c427154e7e40142144d3fb39e20a02&language=en-US&page=1"))
        let data = try! Data(contentsOf: url!)
        let json = try!JSONDecoder().decode(externalID.self, from: data)
        let twitter_id = json.twitter_id
        
        if twitter_id != nil{
            let appURL = NSURL(string: "twitter://twitter.com/"+twitter_id!)!
            let webURL = NSURL(string: "https://twitter.com/"+twitter_id!)!
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                // if Youtube app is not installed, open URL inside Safari
                application.open(webURL as URL)
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
