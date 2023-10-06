//
//  PlayerListTableViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 04/10/2023.
///Users/phi/Desktop/iOS/blindTestIos/BlindTestIos/Controllers/PlayerListTableViewController.swift

import UIKit

class PlayerListTableViewController: UITableViewController {
    

    @IBOutlet var playerTableView: UITableView!
     static var playerData: [[String:Int]] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerTableView.backgroundColor = UIColor.clear

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var rows = PlayerListTableViewController.playerData.count


        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // cell.textLabel?.text = "nique"
        if let artistName = PlayerListTableViewController.playerData[indexPath.row].keys.first{
            var score = PlayerListTableViewController.playerData[indexPath.row].values.first
            cell.textLabel?.text = "\(artistName)  \(score ?? 0)"
        } else {
            cell.textLabel?.text = "Unknown"
        }
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor(red: 1.0, green: 0.533, blue: 0.874, alpha: 1.0)
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.45)

        return cell
    }
    

    func setData(data: [[String : Int]]){
        PlayerListTableViewController.playerData = data
        playerTableView.reloadData()
        print(PlayerListTableViewController.playerData)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let name : String = PlayerListTableViewController.playerData[indexPath.row].keys.first!
        var score =  PlayerListTableViewController.playerData[indexPath.row].values.first
        var newScore : Int = score! + 2
        PlayerListTableViewController.playerData[indexPath.row] = [name : newScore]
        playerTableView.reloadData()
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
