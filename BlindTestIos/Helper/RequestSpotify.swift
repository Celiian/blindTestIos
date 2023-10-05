import Foundation

func getSpotify(type: String, parameter: String,  parameterType: String, completion: @escaping (String?) -> Void) {
    struct DefaultsKeys {
        static let token = "token"
    }
    
    let defaults = UserDefaults.standard
    let acces_token = defaults.string(forKey: DefaultsKeys.token)
    
    var urlBuilt: String
    print(type)
    if type == "search" {
        urlBuilt = "https://api.spotify.com/v1/\(type)?q=\(parameter)&type=\(parameterType)"
    }
    else if type.contains("recommendations")  {
        urlBuilt = "https://api.spotify.com/v1/\(type)\(parameter)\(parameterType)"
    }
    else {
        urlBuilt = "https://api.spotify.com/v1/\(type)/\(parameter)\(parameterType)"
    }
    
    
    print(urlBuilt)
    
    
    if let url = URL(string: urlBuilt) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = acces_token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create a URLSession
        let session = URLSession.shared
        
        // Create a data task for the GET request
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil) // Pass nil to the completion handler in case of an error
                return
            }
            
            if let data = data {
                // Parse and use the response data here
                do {
                    if try JSONSerialization.jsonObject(with: data, options: []) is [String: Any] {
                        // You can extract and process data from the JSON here
                        // For now, let's just convert it back to a string for demonstration
                        let jsonString = String(data: data, encoding: .utf8)
                        completion(jsonString)
                    }
                } catch {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                    completion(nil) // Pass nil to the completion handler in case of a parsing error
                }
            }
        }
        
        // Start the data task
        task.resume()
    }
}
