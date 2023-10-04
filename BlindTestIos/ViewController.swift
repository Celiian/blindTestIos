import UIKit

class ViewController: UIViewController {
    
    var timer: Timer?
    
    struct DefaultsKeys {
        static let token = "token"
    }

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startTimer()
    }
    
    func startTimer() {
        self.getToken()

        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.getToken()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    

    
    
    func getToken(){
        let clientID = "2f4a64e28ea54793970fc88f6b13e079"
        let clientSecret = "37cbcd8728eb42d795e727417bd3a3c9"

        // Define the URL
        if let url = URL(string: "https://accounts.spotify.com/api/token") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Set the Authorization header
            let credentials = "\(clientID):\(clientSecret)"
            let credentialsData = credentials.data(using: .utf8)
            if let base64Credentials = credentialsData?.base64EncodedString() {
                request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            }
            
            // Set the request body data
            let bodyString = "grant_type=client_credentials"
            if let bodyData = bodyString.data(using: .utf8) {
                request.httpBody = bodyData
            } else {
                print("Failed to create body data.")
            }
            
            // Create a URLSession
            let session = URLSession.shared
            
            // Create a data task for the POST request
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    // Parse and use the response data here
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let token = json["access_token"] as? String {
                                print("Access Token: \(token)")
                                let defaults = UserDefaults.standard
                                defaults.set(
                                    token,
                                    forKey: DefaultsKeys.token
                                )
                                
                            }
                        }
                    } catch {
                        print("Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
            
        }

    }

    @IBAction func playClick(_ sender: Any) {
       
        
        if let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mode") as? ModeViewController {
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
}
