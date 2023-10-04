//
//  PlayerViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 04/10/2023.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var embedPlayerListUiView: UIView!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var addPlayerButton: UIButton!
    
    var embedController: PlayerListTableViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "SendPlayerDataSegue" {
            if let embedController
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
