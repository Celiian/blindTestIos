
//
//  GameViewController.swift
//  BlindTestIos
//
//  Created by Philémon Wild on 03/10/2023.
//

import UIKit
import AVFoundation
import YouTubeKit
class GameViewController: UIViewController {
    
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
    
    @IBOutlet weak var video_view: UIView!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var artistInput: UITextField!
    @IBOutlet weak var labels_points: UILabel!
    
    var index: Int = 0
    var action: String = "Commencer"
    
    var totalPoints: Int = 0
    var artistPoints: Int = 0

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.labels_points.text = "Points : \(totalPoints)"
        self.music_name.isHidden = true
        self.trackNumber.isHidden = true
        self.playButton.isHidden = true
        self.titleInput.isHidden = true
        self.artistInput.isHidden = true
        self.video_view.isHidden = true
        self.playButton.titleLabel?.text = "Commencer"
        if(artistChoosen.isEmpty){
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
    
    
    
    func playSound() {
        self.albumCover.isHidden = false
        
        let audioDuration = 10.0
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
                self.playSound()
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
                    
                    self.titleInput.isHidden = false
                    if(!self.artistChoosen.isEmpty){
                        self.artistInput.isHidden = false
                    }
                    
                    self.music_name.text = songName + " - " + artistName
                    
                    self.playButton.setTitle("Valider", for: .normal)
                    self.playButton.isHidden = false
                }
                
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
    
    
    
    
    
    
    
    func performWordComparison(userInput: String, textToGuess: String) -> Float {
        
        func removeContentFromParentheses(_ text: String) -> String {
            var result = ""
            var insideParentheses = false
            
            for char in text {
                if char == "(" {
                    insideParentheses = true
                } else if char == ")" {
                    insideParentheses = false
                }
                
                if !insideParentheses {
                    result.append(char)
                }
            }
            
            return result
        }
        
        func cleanText(_ text: String) -> String {
            let validCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ")
            return String(text.unicodeScalars.filter { validCharacterSet.contains($0) })
        }
        
        func romanToArabic(_ romanNumeral: String) -> Int? {
            let romanNumerals: [Character: Int] = [
                "I": 1,
                "V": 5,
                "X": 10,
                "L": 50,
                "C": 100,
                "D": 500,
                "M": 1000
            ]
            
            var arabicNumeral = 0
            var prevValue = 0
            
            for numeral in romanNumeral.reversed() {
                if let value = romanNumerals[numeral] {
                    if value < prevValue {
                        arabicNumeral -= value
                    } else {
                        arabicNumeral += value
                    }
                    prevValue = value
                } else {
                    return nil
                }
            }
            
            return arabicNumeral
        }
        
        func convertRomanToArabic(_ text: inout String) {
            let regexPattern = "\\b[IVXLCDM]+\\b"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
            
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                let range = Range(match.range, in: text)!
                let romanNumeral = String(text[range])
                
                if let arabicValue = romanToArabic(romanNumeral) {
                    text = text.replacingOccurrences(of: romanNumeral, with: "\(arabicValue)")
                }
            }
        }
        
        func removeContentAfterHyphen(_ text: String) -> String {
            if let range = text.range(of: "-") {
                return String(text.prefix(upTo: range.lowerBound))
            }
            return text
        }
        
        func processText(_ text: inout String) {
            text = removeContentAfterHyphen(text)
            text = cleanText(removeContentFromParentheses(text))
            convertRomanToArabic(&text)
            text = text.trimmingCharacters(in: .whitespaces)
        }
        
        func calculateWordSimilarity(_ word1: String, _ word2: String) -> Double {
            var cleanedWord1 = word1
            var cleanedWord2 = word2
            
            processText(&cleanedWord1)
            processText(&cleanedWord2)
            
            let word1Array = Array(cleanedWord1)
            let word2Array = Array(cleanedWord2)
            
            var dp = [[Int]](repeating: [Int](repeating: 0, count: word2Array.count + 1), count: word1Array.count + 1)
            
            for i in 0...word1Array.count {
                for j in 0...word2Array.count {
                    if i == 0 {
                        dp[i][j] = j
                    } else if j == 0 {
                        dp[i][j] = i
                    } else if word1Array[i - 1] == word2Array[j - 1] {
                        dp[i][j] = dp[i - 1][j - 1]
                    } else {
                        dp[i][j] = 1 + min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
                    }
                }
            }
            
            let maxLen = max(word1Array.count, word2Array.count)
            let similarity = 1.0 - Double(dp[word1Array.count][word2Array.count]) / Double(maxLen)
            
            return similarity
        }
        
        // Appel de la fonction calculatePoints ici
        func calculatePoints(userInput: String, textToGuess: String) -> Float {
            let similarity = calculateWordSimilarity(userInput, textToGuess)
            
            switch similarity {
            case 0.85...1.0:
                return 2.0
            case 0.750..<0.85:
                return 1.5
            case 0.625..<0.750:
                return 1.0
            case 0.5..<0.625:
                return 0.5
            default:
                return 0.0
            }
        }
        
        return calculatePoints(userInput: userInput, textToGuess: textToGuess)
    }
    
    
    @IBAction func clickToCOntinue(_ sender: Any) {
        if(self.action == "Suivant" || self.action == "Commencer"){
            self.video_view.isHidden = true
            self.music_name.isHidden = true
            self.videoPlayer?.pause()
            self.videoPlayer?.replaceCurrentItem(with: nil)
            self.videoPlayer?.seek(to: .zero)
            self.player?.pause()
            
            self.titleInput.text = ""
            if(!artistChoosen.isEmpty){
                self.artistInput.text = ""
                self.artistInput.isHidden = true
            }
            self.titleInput.isHidden = true
            
            self.playButton.isHidden = true
            self.playSound()
            self.action = "Valider"
        }
        else if self.action == "Valider" {
            if(!artistChoosen.isEmpty){
                if let userInput = self.artistInput.text?.uppercased(),
                   let textToGuess = self.music_name.text?.split(separator: "-")[1].uppercased() {
                    let points = self.performWordComparison(userInput: userInput, textToGuess: textToGuess)
                    
                    self.totalPoints += Int(points)
                    self.artistPoints += Int(points)
                }
            }
            if let userInput = self.titleInput.text?.uppercased(),
               let textToGuess = self.music_name.text?.split(separator: "-")[0].uppercased() {
                let points = self.performWordComparison(userInput: userInput, textToGuess: textToGuess)
                
                self.displayVideo()
                DispatchQueue.main.async {
                    self.music_name.isHidden = false
                    self.totalPoints += Int(points)
                    self.labels_points.text = "Points : \(self.totalPoints)"
                    
                    if self.previews_url.count == self.index
                    {
                        self.playButton.setTitle("Score", for: .normal)
                        self.action = "Score"
                    }
                    else {
                        self.playButton.setTitle("Suivant", for: .normal)
                        self.action = "Suivant"
                    }
                    
                }
            }
        }
        else if self.action == "Score" {
            if(self.previews_url.count == self.index){
                if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "scoreBoard") as? FinalScoreViewController {
                    VC.score = self.totalPoints
                    VC.artistPoints = self.artistPoints
                    VC.total = self.previews_url.count
                    VC.simple = self.artistChoosen.count
                    self.navigationController?.pushViewController(VC, animated: true)
                }
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
    
    // Global function to display the video
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
