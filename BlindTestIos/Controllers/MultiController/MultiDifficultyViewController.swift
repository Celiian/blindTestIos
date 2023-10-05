//
//  MultiDifficultyViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 04/10/2023.
//

import UIKit

class MultiDifficultyViewController: UIViewController {

    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var midButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func navClick(_ sender: Any) {

        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "multiCategory") as? MultiCategoryViewController{

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
