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
    
    @IBOutlet weak var continueButton: UIButton!
    var yourDataArray = [AnyObject]()
    var artistChoosen = [AnyObject]()

    
    var difficulty : String  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.artistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.artistTableView.delegate = self
        self.artistTableView.dataSource = self
        self.searchBar.delegate = self
        
        self.artistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.artistTableView.backgroundColor = UIColor.clear

        self.searchBar.searchBarStyle = .minimal
        self.searchBar.searchTextField.backgroundColor = .white
        
        
        if(difficulty == "Simple"){
            self.continueButton.isHidden = true
        }
    }
    
    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // You can change this based on your data structure
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isContained = self.artistChoosen.contains { artist in
            if let artistID = artist["id"] as? String,
               let targetID = yourDataArray[indexPath.row]["id"] as? String {
                return artistID == targetID
            }
            return false
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Configure the cell with data from yourDataArray
        if let artistName = yourDataArray[indexPath.row]["name"] as? String {
            if(isContained){
                cell.textLabel?.text = artistName + " (séléctioné)"
            }
            else {
                cell.textLabel?.text = artistName
            }
        } else {
            cell.textLabel?.text = "Unknown"
        }
        
        if let images = yourDataArray[indexPath.row]["images"] as? [[String: Any]], !images.isEmpty,
           let imageURLString = images[0]["url"] as? String,
           let imageURL = URL(string: imageURLString) {
            cell.imageView?.downloaded(from: imageURL)
        } else {
        }
        
        
        
        if(isContained){
            cell.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        }
        else {
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.45)
            cell.textLabel?.textColor = UIColor(red: 1.0, green: 0.533, blue: 0.874, alpha: 1.0)
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if difficulty == "Simple"{
            if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "multiGame") as? MultiGameViewController {
                VC.artist = yourDataArray[indexPath.row] as? [String : Any]
                VC.difficulty = self.difficulty
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        else {
            let isContained = self.artistChoosen.contains { artist in
                if let artistID = artist["id"] as? String,
                   let targetID = yourDataArray[indexPath.row]["id"] as? String {
                    return artistID == targetID
                }
                return false
            }
            
            if isContained {
                self.artistChoosen.removeAll  { artist in
                    if let artistID = artist["id"] as? String,
                       let targetID = yourDataArray[indexPath.row]["id"] as? String {
                        return artistID == targetID
                    }
                    return false
                }
            }
            else {
                if(self.artistChoosen.count < 5){
                    self.artistChoosen.append(yourDataArray[indexPath.row])
                }
                else {
                    let alertController = UIAlertController(title: "Trop d'artistes", message: "Vous avez selectioné le nombre maximum d'artistes, veuillez en déselectionner ou commencer le blind test.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    // Present the alert
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        DispatchQueue.main.async {
            self.artistTableView.reloadData()
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
                                self.yourDataArray = self.artistChoosen
                                
                                var data = [AnyObject]()
                                
                                for (_, item) in (items as! [AnyObject]).enumerated() {
                                    let isContained = self.artistChoosen.contains { artist in
                                        if let artistID = artist["id"] as? String,
                                           let targetID = item["id"] as? String {
                                            return artistID == targetID
                                        }
                                        return false
                                    }
                                    if !isContained {
                                        if(item["popularity"] as! Int > 30){
                                            data.append(item)
                                        }
                                    }
                                }
                                data.sort { (a, b) -> Bool in
                                    let popularityA = a["popularity"] as? Int ?? 0
                                    let popularityB = b["popularity"] as? Int ?? 0
                                    return popularityA > popularityB
                                }
                                
                                self.yourDataArray.append(contentsOf: data)
                                
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
    
    
    @IBAction func play(_ sender: Any) {
        print(artistChoosen)
        if artistChoosen.count > 0{
            if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "multiGame") as? MultiGameViewController {
                VC.artistChoosen = self.artistChoosen
                VC.difficulty = self.difficulty
                self.navigationController?.pushViewController(VC, animated: true)
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
