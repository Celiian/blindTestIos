//
//  CategoryViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 03/10/2023.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placeholderNavButton: UIButton!
    
    var yourDataArray = [AnyObject]()

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
            
            if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "game") as? GameViewController {
                VC.artist = yourDataArray[indexPath.row] as? [String : Any]
                self.navigationController?.pushViewController(VC, animated: true)
            }

        }
    
    //MARK: - Navigation button
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

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
                           //print(error.localizedDescription)
                        }
                    }
                    
                } else {
                    print("Error or nil result")
                }
            }
        }
}
