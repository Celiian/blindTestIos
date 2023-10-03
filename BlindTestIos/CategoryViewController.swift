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

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var placeholderNavButton: UIButton!
    
    let yourDataArray = ["Item 1", "Item 2", "Item 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.artistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.artistTableView.delegate = self
        self.artistTableView.dataSource = self
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
        cell.textLabel?.text = yourDataArray[indexPath.row]
        cell.imageView?.downloaded(from: URL(string: "https://kultt.fr/wp-content/uploads/2022/09/RickAstley-ad2022.jpg")!)
        
        DispatchQueue.main.async {
                       self.artistTableView.reloadData()
                   }

        return cell
    }
    
    
    // MARK: - Table View Delegate
//
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            // Handle row selection here if needed
//        }
    
    //MARK: - Navigation button
    
    @IBAction func placeholderClick(_ sender: Any) {
        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "game") as? GameViewController{
            self.navigationController?.pushViewController(VC, animated: true)
        }    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
