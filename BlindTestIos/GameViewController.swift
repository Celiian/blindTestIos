//
//  GameViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 03/10/2023.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var artist: [String: Any]?
    var previews_url: [[String: String]] = []
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var music_name: UILabel!
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    
    var player: AVPlayer?
    var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progress.isHidden = true
        self.music_name.isHidden = true
        getSongs()
    }
    
    
    
    func getSongs () {
        let artistId = artist!["id"] as? String
        spinner.startAnimating()
        
        getSpotify(type: "artists", parameter: artistId!, parameterType: "/top-tracks?market=Fr") { result in
            if let result = result {
                if let data = result.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let tracks = json["tracks"] as? [[String: Any]] {
                            
                            let previewDictionary = tracks.compactMap { track in
                                return ["url" : track["preview_url"] as? String ?? "", "name" : track["name"] as? String ?? ""]
                            }
                            
                            self.previews_url = previewDictionary
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } else {
                print("Error or nil result")
            }
        }
        
        
        let audioDuration = 10.0
        let timerDuration = 15.0
        var index = 0
        var progressTimer: Timer? // Declare progressTimer here

        timer = Timer.scheduledTimer(withTimeInterval: timerDuration, repeats: true) { [weak self] _ in
            self?.player?.pause()
            if index < (self?.previews_url.count)! {
             
                if let urlString = self?.previews_url[index]["url"], let audioURL = URL(string: urlString),
                   let songName = self?.previews_url[index]["name"]{
                    self?.player = AVPlayer(url: audioURL)
                    self?.spinner.stopAnimating()
                    self?.spinner.isHidden = true
                    self?.progress.isHidden = false
                    
                    self?.music_name.text = ""
                    self?.music_name.isHidden = true
                    self?.player?.play()
                    
                    // Pause audio after the desired audio duration
                    DispatchQueue.main.asyncAfter(deadline: .now() + audioDuration) {
                        self?.player?.pause()
                    }
                    
                    // Update progress bar every second
                    var seconds = 0.0
                    self?.progress.setProgress(0, animated: true)
                    progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                        guard let self = self else { return }
                        let progressValue = Float(seconds) / Float(audioDuration)
                        self.progress.setProgress(progressValue, animated: true)
                        seconds += 0.1
                        
                         
                        if Int(seconds) > Int(audioDuration) {
                            self.music_name.isHidden = false
                            self.music_name.text = songName
                            progressTimer?.invalidate()
                           
                        }
                    }
                }
                index += 1
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
