
import Foundation

class HTMLParser {
    
    static var videos: [VideoWithContextRenderer] = []
     
     public func search(value: String, completion: @escaping ([VideoWithContextRenderer]?) -> Void) {
         
         let baseUrl = "https://m.youtube.com/results?search_query=" + value
         let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
         let url = URL(string: urlEncoded)
         URLSession.shared.dataTask(with: url!) { data, response, error in
             // if there were any error
             if error != nil || data == nil {
                 print(error as Any)
                 completion(nil)
                 return
             }
             do {
                 let content = String(data: data!, encoding: .utf8)
                 if let videos = self.parse(html: content!) {
                     HTMLParser.videos = videos
                     completion(videos)
                 } else {
                     completion(nil)
                 }
             }
         }.resume()
     }
    
    func parse(html: String) -> [VideoWithContextRenderer]? {
        do {
            if html.contains("ytInitialData") {
                let firsts = html.ranges(of: "ytInitialData")
                let ends = html.ranges(of: "';<")
                _ = html.distance(from: html.startIndex, to: firsts.first!.lowerBound)
                let index = html.distance(from: html.startIndex, to: firsts.first!.lowerBound)
                let ytData = html[html.index(firsts.first!.lowerBound, offsetBy: 17)...html.index(before: ends.first!.lowerBound)].replacingOccurrences(of: "\\x22", with: "\"").replacingOccurrences(of: "\\x7b", with: "{").replacingOccurrences(of: "\\x7d", with: "}").replacingOccurrences(of: "\\x3d", with: "=").replacingOccurrences(of: "\\x5b", with: "[").replacingOccurrences(of: "\\x5d", with: "]").replacingOccurrences(of: "\\x27", with: "'").replacingOccurrences(of: "u0026", with: "&").replacingOccurrences(of: "\\\"", with: "다자바무커").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "다자바무커", with: "\\\"")
                //print(ytData)
                let ytJson = ytData.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let temp = try decoder.decode(VidSearch.self, from: ytJson!)
                
                for item in temp.next {
                    if let results = item.results {
                        // Access and print the results if it's not nil
                        HTMLParser.videos = results
                    } else {
                        // Handle the case where results is nil
                        print("Results is nil for this SectionList")
                    }
                }
                
                return HTMLParser.videos
            }
            print("\n\n")
        }
        catch {
            print(error)
        }
        return nil
    }
}

struct VideoWithContextRenderer: Decodable {
    var videoId: String = "nil"
    
    var vidLength: String = "nil"
    var channelTitle: String = "nil"
    var title: String = "nil"
    
    enum CodingKeys: CodingKey {
        case videoId
        case lengthText
        case shortBylineText
        case headline
        
        case videoWithContextRenderer
    }
    
    enum YtBaseCodingKeys: String, CodingKey {
        case values = "text"
        case runs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if !container.allKeys.contains(.videoWithContextRenderer) {
            return
        }
        let videoContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .videoWithContextRenderer)
        if !videoContainer.contains(.lengthText) {
            return
        }
        self.videoId = try videoContainer.decode(String.self, forKey: .videoId)
        
        let lengthTextContainer = try videoContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self, forKey: .lengthText)
        var lengthTextRunsContainer = try lengthTextContainer.nestedUnkeyedContainer(forKey: .runs)
        let lengthTextRunsContainers = try lengthTextRunsContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self)
        self.vidLength = try lengthTextRunsContainers.decode(String.self, forKey: .values)
        
        let shortBylineTextContainer = try videoContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self, forKey: .shortBylineText)
        var shortBylineTextRunsContainer = try shortBylineTextContainer.nestedUnkeyedContainer(forKey: .runs)
        let shortBylineTextRunsContainers = try shortBylineTextRunsContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self)
        self.channelTitle = try shortBylineTextRunsContainers.decode(String.self, forKey: .values)
        
        let headlineContainer = try videoContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self, forKey: .headline)
        var headlineRunsContainer = try headlineContainer.nestedUnkeyedContainer(forKey: .runs)
        let headlineRunsContainers = try headlineRunsContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self)
        self.title = try headlineRunsContainers.decode(String.self, forKey: .values)
    }
    
}

struct VidSearch:  Decodable {
    
    let next: [SectionList]
    
    enum CodingKeys: String, CodingKey {
        case contents
        case items = "videoWithContextRenderer"
    }
    
    private enum RootContainerKeys: CodingKey {
        case contents
        case sectionListRenderer
    }
    
    private enum SectionListContainerKeys: CodingKey {
        case contents
        case results
    }
    
    private enum ItemSectionContainerKeys: CodingKey {
        case contents
        case itemSectionRenderer
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootContainerKeys.self)
        let contents1Container = try container.nestedContainer(keyedBy: RootContainerKeys.self, forKey: .contents)
        let sectionListContainer = try contents1Container.nestedContainer(keyedBy: SectionListContainerKeys.self, forKey: .sectionListRenderer)
        
        self.next = try sectionListContainer.decode([SectionList].self, forKey: .contents)
        
    }
}

struct SectionList: Decodable {
    var results: [VideoWithContextRenderer]?
    
    enum CodingKeys: CodingKey {
        case results
        case itemSectionRenderer
        case contents
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if !container.allKeys.contains(.itemSectionRenderer) {
            return
        }
        let itemSectionContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .itemSectionRenderer)
        self.results = try itemSectionContainer.decode([VideoWithContextRenderer].self, forKey: .contents)
        
        
        
    }
}
