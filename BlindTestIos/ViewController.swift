//
//  ViewController.swift
//  BlindTestIos
//
//  Created by Célian on 03/10/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func playClick(_ sender: Any) {
        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mode") as? ModeViewController{
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
}

