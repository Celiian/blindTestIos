//
//  DifficultyViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 03/10/2023.
//

import UIKit

class DifficultyViewController: UIViewController {

    @IBOutlet weak var difficultyButton: UIButton!
    @IBOutlet weak var difficultyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func diffClick(_ sender: Any) {
        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "game") as? GameViewController{
            self.navigationController?.pushViewController(VC, animated: true)
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
