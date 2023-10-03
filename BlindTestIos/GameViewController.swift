//
//  GameViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 03/10/2023.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    var artist: [String: Any]?
    var previews_url : [String] = []
    var audioPlayer: AVAudioPlayer?
        
        @IBOutlet weak var playButton: UIButton!

        
        var player: AVPlayer?
        var timer: Timer?
    

        override func viewDidLoad() {
            super.viewDidLoad()

            // Now, you can access the 'artist' dictionary here.
            getSongs()
        }
    
    
    
    func getSongs () {
        let artistId = artist!["id"] as? String
    
        getSpotify(type: "artists", parameter: artistId!, parameterType: "/top-tracks?market=Fr") { result in
            if let result = result {
                if let data = result.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                                  let tracks = json["tracks"] as? [[String: Any]] {
                                                   
                                                   let previewURLs = tracks.compactMap { track in
                                                       return track["preview_url"] as? String
                                                   }

                                                   for url in previewURLs {
                                                       self.previews_url.append(url)
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
        
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            do {
                self?.player?.pause()
                if(index < (self?.previews_url.count)!){
                    if let urlString = self?.previews_url[index], let audioURL = URL(string: urlString) {
                        self?.player = AVPlayer(url: audioURL)
                        self?.player?.play()
                    }
                    index += 1
                }
            }
            catch {
                print("Error initializing AVPlayer: \(error.localizedDescription)")
            }
        }
    }
    
    
    @IBAction func playSound(_ sender: Any) {
        player?.play()

        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(stopSound), userInfo: nil, repeats: false)
    }
    
    @objc func stopSound() {
        player?.pause()
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
