//
//  MultiGameViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 04/10/2023.
//

import UIKit
import AVFoundation
import YouTubeKit

class MultiGameViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playerListUIView: UIView!
    
    @IBOutlet weak var music_name: UILabel!
    var artist: [String: Any]?
    var previews_url: [[String: String]] = []
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var trackNumber: UILabel!
    var player: AVPlayer?
    
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.music_name.isHidden = true
        self.albumCover.isHidden = true
        self.trackNumber.isHidden = true
        self.playButton.isHidden = true
        self.playButton.titleLabel?.text = "Commencer"
        getSongs()

        // Do any additional setup after loading the view.
    }
    
    deinit {
        self.player?.pause()
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
                                else {
                                     if  let name = track["name"] as? String,
                                       let albumImage = track["album"] as? [String: Any],
                                       let albumImages = albumImage["images"] as? [[String: Any]],
                                       let coverURL = albumImages.first?["url"] as? String {
                                        return ["url": "no_url", "name": name, "coverURL": coverURL]
                                    }
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
        self.playButton.isHidden = true
        
        var urlString = String()
        
        if self.previews_url[self.index]["url"] == "no_url" {
            let songName = self.previews_url[self.index]["name"]
           
            getVideoFromYt(songName: songName!) { videoURLString in
                print("Song URL: \(videoURLString)")
                switch videoURLString {
                case .success(let url):
                    let audioURL = url
                    self.playSoundFromUrl(audioURL: audioURL, audioDuration : audioDuration, skip: true)
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            }
        }
        else {
            urlString = self.previews_url[self.index]["url"]!
            let audioURL = URL(string: urlString)
            self.playSoundFromUrl(audioURL: audioURL!, audioDuration : audioDuration, skip: false)
        }
        
    }
    
    func playSoundFromUrl(audioURL : URL, audioDuration : Double, skip : Bool) {
        if let songName = self.previews_url[self.index]["name"],
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
            
            if skip {

                let randomSkipTime = Int(arc4random_uniform(46)) + 25
                let timeToSkip = CMTimeMakeWithSeconds(Float64(randomSkipTime), preferredTimescale: 1)
                player?.seek(to: timeToSkip)
                player?.play()
            }
            else {
                self.player?.play()
            }
            
            animateAndDisappearContainer(duration: audioDuration, disappearanceDuration: 1.0) {
                self.player?.pause()
                self.index += 1
                self.music_name.isHidden = false
                self.music_name.text = songName
                self.albumCover.isHidden = false
                self.playButton.setTitle("Continuer", for: .normal)
                self.playButton.isHidden = false
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
    
    func getVideoFromYt(songName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let parser = HTMLParser()
        var video_id = ""
        parser.search(value: songName) { videos in
            if let videos = videos {
                print("Total videos found: \(HTMLParser.videos.count)")
                video_id = videos[1].videoId
                
                self.getUrlFromId(video_id: video_id) { result in
                    switch result {
                    case .success(let url):
                        completion(.success(url))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            } else {
                print("Error parsing HTML or no videos found.")
            }
        }

    }
    
    func getUrlFromId(video_id: String, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                let stream = try await YouTube(videoID: video_id).streams
                                          .filterAudioOnly()
                                          .filter { $0.subtype == "mp4" }
                                          .highestAudioBitrateStream()
                
                completion(.success(stream!.url))
            } catch {
                completion(.failure(error))
            }
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
