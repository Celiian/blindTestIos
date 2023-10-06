import UIKit
import AVFoundation
import YouTubeKit

class MultiGameViewController: UIViewController {
    
    @IBOutlet weak var playerListUIView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var artist: [String: Any]?
    var artistChoosen = [AnyObject]()
    
    var previews_url: [[String: String]] = []
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var music_name: UILabel!
    
    @IBOutlet weak var trackNumber: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var player: AVPlayer?
    var videoPlayer: AVPlayer?
    
    var video_url: URL? = URL(string: "")
    var difficulty : String = ""
    
    @IBOutlet weak var video_view: UIView!
    
    var index: Int = 0
    var action: String = "Commencer"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.music_name.isHidden = true
        self.trackNumber.isHidden = true
        self.playButton.isHidden = true
        self.video_view.isHidden = true
        self.playButton.titleLabel?.text = "Commencer"
        if(self.difficulty == "Simple"){
            getSongsSimple()
        }
        else {
            getSongs()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.player?.pause()
    }
    
    
    
    func getSongsSimple () {
        let artistId = artist!["id"] as? String
        spinner.startAnimating()
        self.previews_url = []
        
        getSpotify(type: "artists", parameter: artistId!, parameterType: "/top-tracks?market=Fr") { result in
            if let result = result {
                if let data = result.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let tracks = json["tracks"] as? [[String: Any]] {
                            
                            
                            var previewDictionary = tracks.compactMap { track in
                                if  let name = track["name"] as? String,
                                    let artists = track["artists"] as? [[String: AnyObject]],
                                    let artistName = artists.first?["name"] as? String{
                                    
                                    return ["name": name, "artist" : artistName]
                                }
                                return nil
                            }
                            
                            previewDictionary.shuffle()
                            
                            
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
    
    
    func getSongs () {
        
        if let artistChoosen = self.artistChoosen as? [[String: Any]] {
            let artistsIds = self.artistChoosen.compactMap { $0["id"] as? String }
            let genres = artistChoosen.compactMap { dictionary in
                if let genresArray = dictionary["genres"] as? [String], let firstGenre = genresArray.first {
                    return firstGenre
                }
                return nil
            }
            spinner.startAnimating()
            self.previews_url = []
            
            
            self.getTracks(artistIds: artistsIds, genres: genres)
        } else {
            // Handle the case where 'self.artistChoosen' is not of the expected type.
        }
    }
    
    func getTracks(artistIds: [String], genres: [String]) {
        getSpotify(type: "recommendations?limit=50&seed_artists=", parameter: artistIds.joined(separator: "%2C"), parameterType: "&min_popularity=50") { result in
            if let result = result {
                if let data = result.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let tracks = json["tracks"] as? [[String: Any]] {
                            
                            var previewDictionary = tracks.compactMap { track in
                                if  let name = track["name"] as? String,
                                    let artists = track["artists"] as? [[String: AnyObject]],
                                    let artistName = artists.first?["name"] as? String{
                                    
                                    return ["name": name, "artist" : artistName]
                                }
                                return nil
                            }
                            
                            previewDictionary.shuffle()
                            
                            
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
    
    func preloadVideo(videoUrl : URL) {
        let playerItem = AVPlayerItem(url: videoUrl)
        self.videoPlayer = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: self.videoPlayer)
        playerLayer.frame = self.video_view.bounds
        self.video_view.layer.addSublayer(playerLayer)
    }
    
    
    
    func playSound() {
        self.albumCover.isHidden = false

        var audioDuration = 0.0
        
        if self.difficulty == "Difficile"{
            audioDuration = 5.0
        }
        else {
            audioDuration = 10.0
        }
        
        self.playButton.isHidden = true
        
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        let songName = self.previews_url[self.index]["name"]
        let artistName = self.previews_url[self.index]["artist"]
        
        let search = (songName?.contains("feat") ?? true) ? songName! : "\(songName ?? "") \(artistName ?? "")"
        
        
        
        self.getAudioFromYt(songName: search) { videoURLString in
            switch videoURLString {
            case .success(let url):
                let audioURL = url
                self.getVideoFromYt(songName: search) { videoURLString in
                    switch videoURLString {
                    case .success(let url):
                        self.video_url = url
                        self.preloadVideo(videoUrl : url)
                    case .failure(let error):
                        print("Failed with error: \(error)")
                    }
                }
                
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.playSoundFromUrl(audioURL: audioURL, audioDuration : audioDuration, skip: true)
            case .failure(let error):
                print("Failed with error: \(error)")
                self.index += 1
                
                if  (self.index == self.previews_url.count){
                    self.playButton.setTitle("Scores", for: .normal)
                    self.action = "score"
                }
                else {
                    self.playSound()
                }   
            }
        }
    }
    
    
    func playSoundFromUrl(audioURL : URL, audioDuration : Double, skip : Bool) {
        if let songName = self.previews_url[self.index]["name"],
           let artistName = self.previews_url[self.index]["artist"]{
            self.player = AVPlayer(url: audioURL)
            
            
            
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
                let randomSkipTime = Int.random(in: 0...20)
                let timeToSkip = CMTimeMakeWithSeconds(Float64(randomSkipTime), preferredTimescale: 1)
                player?.seek(to: timeToSkip)
                player?.play()
            }
            
            animateAndDisappearContainer(duration: audioDuration, disappearanceDuration: 1.0) {
                self.player?.pause()
                self.index += 1
                
                DispatchQueue.main.async {
                    
                    
                    self.music_name.text = songName + " - " + artistName
                    
                    if  (self.index == self.previews_url.count){
                        self.playButton.setTitle("Scores", for: .normal)
                        self.action = "score"
                    }
                }
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
        let containerWidth: CGFloat = screenWidth * 0.65
        let containerHeight: CGFloat = screenHeight * 0.01
        let containerX = (screenWidth - containerWidth) / 2
        let containerY = screenHeight * 0.75 - containerHeight / 2
        
        let containerView = UIView(frame: CGRect(x: containerX, y: containerY, width: containerWidth, height: containerHeight))
        
        let fillView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: containerHeight))
        fillView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.99, alpha: 1.0)
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
    
    
    
    func getAudioFromYt(songName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let parser = HTMLParser()
        var video_id = ""
        parser.search(value: songName) { videos in
            if let videos = videos {
                print("Total videos found: \(HTMLParser.videos.count)")
                video_id = videos[1].videoId
                
                self.getUrlAudioFromId(video_id: video_id) { result in
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
    
    
    func getVideoFromYt(songName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let parser = HTMLParser()
        var video_id = ""
        parser.search(value: songName) { videos in
            if let videos = videos {
                print("Total videos found: \(HTMLParser.videos.count)")
                video_id = videos[1].videoId
                self.getUrlVideoFromId(video_id: video_id) { result in
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
    
    
    
    
    func getUrlAudioFromId(video_id: String, completion: @escaping (Result<URL, Error>) -> Void) {
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
    
    func getUrlVideoFromId(video_id: String, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                let stream = try await YouTube(videoID: video_id).streams.filter { $0.subtype == "mp4" }.highestResolutionStream()
                completion(.success(stream!.url))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    
    @IBAction func clickToCOntinue(_ sender: Any) {
        if self.action == "score" {
            if(self.previews_url.count == self.index){
                if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "scoreBoard") as? FinalScoreViewController {
                    VC.total = self.previews_url.count
                    VC.simple = self.artistChoosen.count
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }
        }
        else if(self.action == "Suivant" || self.action == "Commencer"){
            self.video_view.isHidden = true
            self.music_name.isHidden = true
            self.videoPlayer?.pause()
            self.videoPlayer?.replaceCurrentItem(with: nil)
            self.videoPlayer?.seek(to: .zero)
            self.player?.pause()
            
            self.playButton.isHidden = true
            self.action = "Réponse"
            self.playButton.setTitle("Réponse", for: .normal)
            self.playSound()
        }
        else if self.action == "Réponse" {
            self.music_name.isHidden = false
            self.action = "Suivant"
            self.playButton.setTitle("Suivant", for: .normal)
            self.displayVideo()
            
        }
    }
    
    func displayVideo() {
        
        
        let playerTime = self.player!.currentTime()
        
        let initialTimeInterval = TimeInterval(playerTime.value) / TimeInterval(playerTime.timescale)
        let updatedTimeInterval = initialTimeInterval + 1.0
        let playerTimePlusOne = CMTime(value: Int64(updatedTimeInterval * TimeInterval(playerTime.timescale)), timescale: playerTime.timescale)
        
        
        DispatchQueue.main.async {
            
            self.videoPlayer?.seek(to: playerTimePlusOne)
            self.player?.seek(to: playerTime)
            
            self.player?.play()
            self.videoPlayer?.play()
            self.albumCover.isHidden = true
            
            
            self.video_view.isHidden = false
            
        }
    }
}


