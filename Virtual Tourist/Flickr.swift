//
//  Flickr.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit



class Flickr:NSObject {
    
    class func sharedInstance()->Flickr{
        struct Singleton {
            static let shared = Flickr()
        }
        return Singleton.shared
    }
    
    private var lastErrorCode:Int?
    
    private let flickrAPIKey = "60d992c9c1aed6e8cfda4708a1ca46ca"

    private let baseURL = "https://api.flickr.com/services/rest/"
    private let searchMethod = "flickr.photos.search"
    private let imageURLSizeTag = "url_m"  //for extras parameter and result parsing
    private let dataFormat = "json"
    private let noJsonCallback = "1"
    private let boundingBoxDelta:Double = 1.0
    private let perPage = "20"
    private let basePhotoURLString = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
    
    ///keys for resultDict used in completionHandler for getImagesForCoordinates
    struct ResultKeys {
        static let imageURLs = "imageURLs"
        static let thisPage = "thisPage"
        static let totalPages = "totalPages"
        static let error = "error"
    }
    
    
    private let resultDictBase:[String:AnyObject] = [
    ResultKeys.imageURLs: [String](),
    ResultKeys.thisPage: -1,
    ResultKeys.totalPages: -1
    ]
    

    /**
        getImagesForCoordinates()
        completionHandler resultDict format:
    
    */
    
    func getImagesForCoordinates(#latitude:Double,longitude:Double, page:Int?,completionHandler:(resultDict:[String:AnyObject])->Void)->NSURLSessionDataTask {

        let session = NSURLSession.sharedSession()
        let request = requestWithParametersForLocation(latitude: latitude, longitude: longitude, page: page)
        
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var resultDict = self.resultDictBase
            if error != nil {
                println("Error in dataTaskWithRequest in getImages:")
                println(error!)
                resultDict[ResultKeys.error] = error!
                self.lastErrorCode = error!.code
            } else {
                var imageURLArray:[String] = []
                self.lastErrorCode = nil
                var parseError:NSError?
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &parseError) as! [String:AnyObject]
                if parseError != nil {
                    println("parsing error in getImages")
                    println(parseError!.localizedDescription)
                    resultDict[ResultKeys.error] = parseError!
                } else if let photosDict = parsedJSON["photos"] as? [String:AnyObject] {
                    if let thisPage = photosDict["page"] as? Int, totalPages = photosDict["pages"] as? Int, totalPhotos = (photosDict["total"] as? String)?.toInt() {
                        resultDict[ResultKeys.thisPage] = thisPage
                        resultDict[ResultKeys.totalPages] = totalPages
                        if totalPhotos > 0 {
                            if let photoArray = photosDict["photo"] as? [[String:AnyObject]] {
                                var photoURLStrings:[String] = []
                                for photoElement in photoArray {
                                    if let url = photoElement[self.imageURLSizeTag] as? String {
                                        photoURLStrings.append(url)
                                    }
                                }
                                resultDict[ResultKeys.imageURLs] = photoURLStrings
                            } else {
                                println("photosArray could not be created")
                            }
                            
                        } else {
                            println("no photos at location")
                        }
                    } else {
                        println("invalid/no values in thisPage/totalPages/totalPhotos")
                    }
                    
                } else {
                    let errorDescription = "photosDict could not be created from parsedJSON[photos]"
                    println(errorDescription)
                    resultDict[ResultKeys.error] = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedDescriptionKey:errorDescription])

                }
            }
            completionHandler(resultDict: resultDict)
        })
        dataTask.resume()
        return dataTask
    }
    
    
    func retrieveImageFromURL(urlString:String,completionHandler:(fileLocationURL:NSURL?)->Void)->NSURLSessionDownloadTask {
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        let session = NSURLSession.sharedSession()
        
        let downloadTask = session.downloadTaskWithRequest(request, completionHandler: { (fileURL, response, downloadError) -> Void in
            if downloadError != nil {
                println("Error downloading image \(downloadError!.localizedDescription)")
                self.lastErrorCode = downloadError!.code
                completionHandler(fileLocationURL: nil)
            } else {
                self.lastErrorCode = nil
                completionHandler(fileLocationURL: fileURL!)
            }
        })
        downloadTask.resume()
        return downloadTask
    }
    
    func constructImageURLStringFromDict(dict:[String:AnyObject])->String?{
        // "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
        var urlString = basePhotoURLString
        //basePhotoURLString.stringByReplacingOccurrencesOfString("{farm-id}", withString: <#String#>, options: <#NSStringCompareOptions#>, range: <#Range<String.Index>?#>)
        return urlString
        //FIXME: fix or remove this function
    }
    
    private func requestWithParametersForLocation(#latitude:Double,longitude:Double,page:Int?)->NSURLRequest {
        var methodArgs:[String:String] = [
            "method": searchMethod,
            "api_key": flickrAPIKey,
            "bbox": boundingBoxForLocation(latitude:latitude, longitude: longitude),
            "extras": imageURLSizeTag,
            "format": dataFormat,
            "nojsoncallback": noJsonCallback,
            "per_page": perPage
        ]
        if let pageNumber = page {
            methodArgs["page"] = "\(pageNumber)"
        }
        let urlString = baseURL + escapedParameters(methodArgs)
        let url = NSURL(string: urlString)!
        return NSURLRequest(URL: url)
    }
    
    private func boundingBoxForLocation(#latitude:Double,longitude:Double) -> String {
        //we don't bother checking if some parts of the bounding box are invalid since at least some parts will be valid (since we know the coordinated being passed in are valid) and because the flickr api adjusts bounds itself.
        return "\(longitude - boundingBoxDelta),\(latitude - boundingBoxDelta),\(longitude + boundingBoxDelta),\(latitude + boundingBoxDelta)"
    }
    
    private func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    ///Check if the most recent task completed did so with a connection error.
    func connectionIsOffline()->Bool{
        if self.lastErrorCode == -1009 {
            return true
        } else {
            return false
        }
    }
}
