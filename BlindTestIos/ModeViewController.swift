//
//  ModeViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 03/10/2023.
//

import UIKit

class ModeViewController: UIViewController {

    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var soloButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func soloModeClick(_ sender: Any) {
        print("su")
        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "difficulty") as? DifficultyViewController{
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    @IBAction func modeClick(_ sender: Any) {
        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "difficulty") as? DifficultyViewController{
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
