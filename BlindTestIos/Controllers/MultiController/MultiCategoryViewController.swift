//
//  MultiCategoryViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 04/10/2023.
//

import UIKit

class MultiCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var artistTableView: UITableView!
    
    var yourDataArray = [AnyObject]()
    var difficulty = "Simple"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.artistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.artistTableView.delegate = self
        self.artistTableView.dataSource = self
        self.searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // You can change this based on your data structure
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell with data from yourDataArray
        if let artistName = yourDataArray[indexPath.row]["name"] as? String {
            cell.textLabel?.text = artistName
            
        } else {
            cell.textLabel?.text = "Unknown"
        }
        
        if let images = yourDataArray[indexPath.row]["images"] as? [[String: Any]], !images.isEmpty,
           let imageURLString = images[0]["url"] as? String,
           let imageURL = URL(string: imageURLString) {
            cell.imageView?.downloaded(from: imageURL)
        } else {

        }
       
        return cell
    }
    
    // MARK: - Table View Delegate
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "multiGame") as? MultiGameViewController {
                // difficulty is either "Simple" "Medium" or "Hard
                if difficulty == "Simple"{
                    VC.artist = yourDataArray[indexPath.row] as? [String : Any]
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }

        }
    
    // MARK: - SearchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
       
            getSpotify(type: "search", parameter: searchText, parameterType: "artist") { result in
                if let result = result {
                    
                    if let data = result.data(using: .utf8) {
                        do {
                            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let artists = dictionary["artists"] as? [String: Any], let items = artists["items"] {
                                    self.yourDataArray = []
                                    
                                    for (_, item) in (items as! [AnyObject]).enumerated() {
                                        if(item["popularity"] as! Int > 30){
                                            self.yourDataArray.append(item)
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.artistTableView.reloadData()
                                    }
                                } else {
                                    print("No 'items' key in 'artists' dictionary.")
                                }
                            }
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                } else {
                    print("Error or nil result")
                }
            }
        }
    

//    @IBAction func navClick(_ sender: Any) {
//        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "multiGame") as? MultiGameViewController{
//            self.navigationController?.pushViewController(VC, animated: true)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
