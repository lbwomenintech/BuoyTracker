//
//  BuoyService.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

enum APIError: Error {
    case noData
}

enum ParsingState {
    case none
    case parsingTitle
    case parsingDescription
    case parsingId
    case parsingCoordinates
}

protocol BuoyRequester: AnyObject {
    func reloadData()
    var buoyList: [Buoy] { get set }
}

let hardCodedLocation = CLLocation(latitude: 40.0, longitude: -73.0)

extension BuoyRequester {
    
    // NOTE: I made this more general to make it easier to pass in other locations
    func fetchBuoyData(fromLocation location: CLLocation) {
        BuoyService.getBuoyData(fromLocation: location) { [weak self] (buoys: [Buoy]?, error: Error?) in
            guard error == nil else { return }
            
            if let buoys = buoys {
                self?.buoyList = buoys
            }
            
            DispatchQueue.main.sync {
                self?.reloadData()
            }
        }
    }
}

class BuoyService: NSObject, URLSessionTaskDelegate {
    
    static let shared = BuoyService()
    
    // data cache
    var buoyList: [Buoy] = []
    
    // data persistence key
    private static let favoriteBuoyListKey: String = "favoriteBuoyList"
    
    // URL service properties
    private let session: URLSession = URLSession.shared
    private var dataTask: URLSessionDataTask?
    
    // parsing properties
    fileprivate var currentBuoy: Buoy?
    fileprivate var parserState: ParsingState = .none

    static func getBuoyData(fromLocation location: CLLocation, _ completion: @escaping ((_ buoyList: [Buoy]?, _ error: Error?) -> Void)) {
        let route: Routes = Routes.buoyFeed(location: location, radius: 100)
        shared.dataTask?.cancel()
        
        if let url = URL(string: route.path) {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            shared.dataTask = shared.session.dataTask(with: url) { (data, response, error) in
                
                DispatchQueue.main.sync {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let error = error {
                    print("Something went wrong: \(error)")
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, APIError.noData)
                    return
                }
                
                // empty buoy list
                shared.buoyList = []
                
                // parse objects from XML
                let parser = XMLParser(data: data)
                parser.delegate = shared
                parser.parse()
                
                completion(shared.buoyList, nil)
            }
            
            shared.dataTask?.resume()
        }
    }
    
    // MARK: - Favorite Methods
    static func getFavoriteBuoys() -> [Buoy] {
        let favoriteIdList = BuoyService.getFavoriteBuoyIds()
        let favoriteBuoys = shared.buoyList.filter({
            if let stationId = $0.stationId {
                return favoriteIdList.contains(stationId)
            } else {
                return false
            }
        })
        return favoriteBuoys
    }
    
    static func getFavoriteBuoyIds() -> [String] {
        let standardDefaults = UserDefaults.standard
        return standardDefaults.object(forKey: favoriteBuoyListKey) as? [String] ?? [String]()
    }
    
    // NOTE: I'm operating under the assumption that the guid of the buoy is a
    //       constant unique identifier. If this doesn't hold, my favoriting system
    //       likely won't work.
    static func addFavorite(buoy: Buoy) {
        var favoriteBuoyList = getFavoriteBuoyIds()
        if let stationId = buoy.stationId {
            if favoriteBuoyList.contains(stationId) {
                return
            } else {
                let standardDefaults = UserDefaults.standard
                favoriteBuoyList.append(stationId)
                standardDefaults.set(favoriteBuoyList, forKey: favoriteBuoyListKey)
                standardDefaults.synchronize()
            }
        }
    }
    
    static func removeFavorite(buoy: Buoy) {
        var favoriteBuoyList = getFavoriteBuoyIds()
        
        if let stationId = buoy.stationId,
            let index = favoriteBuoyList.index(of: stationId) {
            
            favoriteBuoyList.remove(at: index)
            
            let standardDefaults = UserDefaults.standard
            standardDefaults.set(favoriteBuoyList, forKey: favoriteBuoyListKey)
            standardDefaults.synchronize()
        }
    }
}

extension BuoyService: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            currentBuoy = Buoy()
            parserState = .none
        }
        
        if elementName == "title" {
            parserState = .parsingTitle
        }
        
        if elementName == "georss:point" {
            parserState = .parsingCoordinates
        }
        
        if elementName == "description" {
            parserState = .parsingDescription
        }
        
        // NOTE: I'm operating under the assumption that the guid of the buoy is a
        //       constant unique identifier. If this doesn't hold, my favoriting system
        //       likely won't work.
        if elementName == "guid" {
            parserState = .parsingId
        }
        
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        parserState = .none
        
        if elementName == "item" {
            
            if let currentBuoy = currentBuoy {
                buoyList.append(currentBuoy)
            }
            
            currentBuoy = nil
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if parserState == .parsingId {
            currentBuoy?.stationId = string
        }
        
        if parserState == .parsingTitle {
            currentBuoy?.name = string
        }
        
        if parserState == .parsingDescription {
            currentBuoy?.descriptionString = string
        }
        
        if parserState == .parsingCoordinates {
            let coordinates = string.components(separatedBy: " ")
            guard coordinates.count > 1 else { return }
            currentBuoy?.latitude = Double(coordinates[0])
            currentBuoy?.longitude = Double(coordinates[1])
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // pass
    }
}
