//
//  favoriteViewController.swift
//  Lab4
//
//  Created by RUI WANG on 10/13/19.
//  Copyright © 2019 RUI WANG. All rights reserved.
//

import UIKit

class favoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    var favorite:[String]? = []
//    let favorite = defaults.stringArray(forKey: "movieNameKey")
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorite.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
        cell.textLabel!.text = favorite[indexPath.row]
        return cell
    }
    

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favorite.removeAll()
        if defaults.array(forKey: "movieNameKey") != nil{
            let savedMovie:[String] = defaults.array(forKey: "movieNameKey")as! [String]
            for item in savedMovie{
                favorite.append(item)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favorite.remove(at: indexPath.row)
            defaults.removeObject(forKey: "movieNameKey")
            defaults.set(favorite, forKey: "movieNameKey")
            tableView.deleteRows(at: [indexPath], with: .fade)
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
