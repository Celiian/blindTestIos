//
//  FinalScoreViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 04/10/2023.
//

import UIKit

class FinalScoreViewController: UIViewController {

    
    var score : Int = 0
    var artistPoints : Int = 0
    var total : Int = 0
    var simple : Int = 0
    @IBOutlet weak var scoreDisplay: UILabel!
    
    @IBOutlet weak var chansons: UILabel!
    @IBOutlet weak var SongsFound: UILabel!
    @IBOutlet weak var artistesFound: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.simple == 0){
            self.scoreDisplay.text = "\(self.score)  /  \(self.total * 2)"
            self.artistesFound.isHidden = true
            self.SongsFound.text = "Chansons trouvés : \(self.score / 2)"

        }
        else {
            self.scoreDisplay.text = "\(self.score)  /  \(self.total * 4)"
            self.SongsFound.text = "Chansons trouvés : \((self.score - self.artistPoints) / 2)"
            self.artistesFound.text = "Artistes trouvés : \(self.artistPoints / 2)"
            
        }

        self.chansons.text = "Chansons : \(self.total)"
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
