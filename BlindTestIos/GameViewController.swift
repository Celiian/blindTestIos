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
    
    @IBOutlet weak var trackNumber: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var player: AVPlayer?
    var timer: Timer?
    var index: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.music_name.isHidden = true
        self.albumCover.isHidden = true
        self.trackNumber.isHidden = true
        self.playButton.isHidden = true
        self.playButton.titleLabel?.text = "Commencer"
        getSongs()
    }

    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }

    
    
    
    func getSongs () {
        let artistId = artist!["id"] as? String
        spinner.startAnimating()
        self.previews_url = []
        
        getSpotify(type: "artists", parameter: artistId!, parameterType: "/top-tracks?market=Fr") { result in
            if let result = result {
                if let data = result.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let tracks = json["tracks"] as? [[String: Any]] {
                            
                            let previewDictionary = tracks.compactMap { track in
                                if let previewURL = track["preview_url"] as? String,
                                   let name = track["name"] as? String,
                                   let albumImage = track["album"] as? [String: Any],
                                   let albumImages = albumImage["images"] as? [[String: Any]],
                                   let coverURL = albumImages.first?["url"] as? String {
                                    return ["url": previewURL, "name": name, "coverURL": coverURL]
                                }
                                return nil
                            }

                            
                            self.previews_url = previewDictionary
                            DispatchQueue.main.async {
                                self.playButton.isHidden = false
                                self.spinner.stopAnimating()
                                self.spinner.isHidden = true
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
        
        
       

    }
    
    @IBAction func playSound(_ sender: Any) {
        let audioDuration = 10.0
        let timerDuration = 15.0
        self.playButton.isHidden = true
        
        var progressTimer: Timer?
                
        if let urlString = self.previews_url[self.index]["url"], let audioURL = URL(string: urlString),
           let songName = self.previews_url[self.index]["name"],
           let coverUrl = self.previews_url[self.index]["coverURL"]{
            self.player = AVPlayer(url: audioURL)
            self.albumCover.isHidden = true
            
            if let url = URL(string: coverUrl) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.albumCover.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
            
            
            
            self.trackNumber.text = "\(index + 1) / \(self.previews_url.count )"
            self.trackNumber.isHidden = false
            self.music_name.text = ""
            self.music_name.isHidden = true
            self.player?.play()
            
            animateAndDisappearContainer(duration: audioDuration, disappearanceDuration: 1.0) {
                self.player?.pause()
                self.index += 1
                self.music_name.isHidden = false
                self.music_name.text = songName
                self.albumCover.isHidden = false
                self.playButton.setTitle("Continuer", for: .normal)
                self.playButton.isHidden = false
                progressTimer?.invalidate()
            }

            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + audioDuration) {
                self.player?.pause()
            }
            
            
            
        }
        
    }
    
    @objc func animateAndDisappearContainer(duration: TimeInterval, disappearanceDuration: TimeInterval, completionHandler: @escaping () -> Void) {
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height
            let containerWidth: CGFloat = screenWidth * 0.8
            let containerHeight: CGFloat = screenHeight * 0.05
            let containerX = (screenWidth - containerWidth) / 2
            let containerY = screenHeight * 0.75 - containerHeight / 2

            let containerView = UIView(frame: CGRect(x: containerX, y: containerY, width: containerWidth, height: containerHeight))
            containerView.backgroundColor = UIColor.white
            containerView.layer.cornerRadius = containerHeight / 2
            containerView.layer.borderWidth = 1.0
            containerView.layer.borderColor = UIColor.black.cgColor

            let fillView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: containerHeight))
            fillView.backgroundColor = UIColor.green
            fillView.layer.cornerRadius = containerHeight / 2
            containerView.addSubview(fillView)

            self.view.addSubview(containerView)

            UIView.animate(withDuration: duration, animations: {
                fillView.frame.size.width = containerView.frame.width
            }) { (completed) in
                if completed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + disappearanceDuration) {
                        UIView.animate(withDuration: disappearanceDuration, animations: {
                            containerView.alpha = 0.0
                        }) { (finished) in
                            if finished {
                                containerView.removeFromSuperview()
                                completionHandler()
                            }
                        }
                    }
                }
            }
        }
    
    @objc func stopSound() {
        player?.pause()
    }
   
 

}
