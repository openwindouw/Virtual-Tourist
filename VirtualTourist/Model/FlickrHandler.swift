//
//  FlickrHandler.swift
//  Virtual Tourist
//
//  Created by User on 12/23/17.
//  Copyright © 2017 administrator. All rights reserved.
//

import UIKit

class FlickrHandler: NSObject {
    // shared session
    
    var session = URLSession.shared
    
    func request(verb: HTTPMethod = .get, parameters: VTDictionary? = nil, jsonBody: VTDictionary? = nil, completionHandler: @escaping( _ result: Any?, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: URLFromParameters(parameters))
        request.httpMethod = verb.method()
        
        
        if let jsonBody = jsonBody {
            request.httpBody = Util.prepareForJsonBody(jsonBody)
        }
        
        if verb == .put || verb == .post {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
            
        }
        
        task.resume()        
    }
    
    class func shared() -> FlickrHandler {
        struct Singleton {
            static var sharedInstance = FlickrHandler()
        }
        return Singleton.sharedInstance
    }
    
    private func URLFromParameters(_ parameters: VTDictionary?) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrHandler.Constants.ApiScheme
        components.host = FlickrHandler.Constants.ApiHost
        components.path = FlickrHandler.Constants.ApiPath
        components.queryItems = [URLQueryItem]()
        
        if var parameters = parameters {
            
            parameters["api_key"] = FlickrHandler.Constants.ApiKey
            parameters["safe_search"] = "1"
            parameters["format"] = "json"
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}

extension FlickrHandler {
    struct Constants {
        // MARK: API Key
        static let ApiKey = "424d08d26e5c2dc68ee0eae8e482ae87"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct Methods {
        static let SearchPhotos = "flickr.photos.search"
    }
}
