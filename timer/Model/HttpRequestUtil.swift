//
//  HttpRequestUtil.swift
//  timer
//
//  Created by linhai on 2021/7/28.
//

import Foundation
import SwiftUI



extension URL {
public var parametersFromQueryString : [String: String]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
        let queryItems = components.queryItems else { return nil }
    return queryItems.reduce(into: [String: String]()) { (result, item) in
        result[item.name] = item.value
    }
}}

class HttpRequestUtil: NSObject {
    
    var session: URLSession = URLSession(configuration: .default)
    var url: URL?
    
    
    override init() {
        
    }
    
    
    func request() {
        let queryParams = ["vendor": "qq", "method": "searchSong", "params": "[{\"keyword\":\"周杰伦\"}]"]
        var baseUrlString = "https://suen-music-api.leanapp.cn/"
//        queryParams["ff"] = "fff"
        var i = 0
        for (k, v) in queryParams {
            if i == 0 {
                baseUrlString.append("?")
            }
            baseUrlString.append("\(k)=\(v)")
            if i < queryParams.count - 1 {
                baseUrlString.append("&")
            }
            i += 1
            
        }
        // https://suen-music-api.leanapp.cn/?vendor=qq&method=searchSong&params=[{"keyword":"周杰伦"}]
        let baseUrl = URL(string: baseUrlString)!
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.addValue("Content-Type", forHTTPHeaderField: "application/json")
        session.dataTask(with: request) { data, response, err in
            if let resultData: Data = data{
                do {
                    let searchSongs = try JSONDecoder().decode(SearchSongs.self, from: resultData)
//                    let responseJSON = try JSONSerialization.jsonObject(with: resultData, options:[.mutableContainers,.mutableLeaves])
//                    if let responseJSON = responseJSON as? [String: Any] {
//                            print(responseJSON)
//                        }
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let jsonData2 = try! encoder.encode(searchSongs)
                    print(String(bytes: jsonData2, encoding: String.Encoding.utf8) ?? "")
                } catch {
                    print("error")
                }
            }
        }
        .resume()
    }
    
}





struct SearchSongs: Codable {
    let status: Bool?
    let data: [Sdata]?
    
    struct Sdata: Codable {
        let total: Int
        let songs: [Song]
        
        struct Song: Codable {
            let album: Album
            let artists: [Artist]
            let name: String
            let link: String
            let id: Int
            let cp: Bool
            let dl: Bool
            let quality: [Quality]
            let mv: String
            let vendor: String
            
            struct Album: Codable {
                let id: Int
                let name: String
                let cover: String
            }
            struct Artist: Codable {
                let id: Int
                let name: String
            }
            struct Quality: Codable {
                // "quality": {
//                "192": true,
//                "320": true,
//                "999": true
//                }
                let qu192: Bool
                let qu320: Bool
                let qu999: Bool
                private enum CodingKeys: String, CodingKey {
                    case qu192 = "192"
                    case qu320 = "320"
                    case qu999 = "999"
                }
            }
            
        }
    }
    
}




