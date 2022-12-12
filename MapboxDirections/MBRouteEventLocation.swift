//
//  File.swift
//  MapboxDirections
//
//  Created by phonex on 12/12/2022.
//  Copyright © 2022 Mapbox. All rights reserved.
//

import Foundation


@objc(MBRouteEventLocation)
open class RouteEventLocation: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(type, forKey: "type")
        coder.encode([
            "latitude": location.latitude,
            "longitude": location.longitude,
        ], forKey: "location")
        
    }
    
    public required init?(coder decoder: NSCoder) {
        if let locationDict = decoder.decodeObject(of: [NSDictionary.self, NSString.self, NSNumber.self], forKey: "location") as? [String: CLLocationDegrees],
            let latitude = locationDict["latitude"],
            let longitude = locationDict["longitude"] {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            location = kCLLocationCoordinate2DInvalid
        }
        guard let decodedType = decoder.decodeObject(of: NSString.self, forKey: "type") as String? else {
            return nil
        }
        type = decodedType
    }
    
    // MARK: Creating a Step
    
    internal init(location: CLLocationCoordinate2D, type: String) {
        self.location = location
        self.type = type
    }
    
    /**
     Initializes a new route step object based on the given JSON dictionary representation.
     
     Normally, you do not create instances of this class directly. Instead, you receive route step objects as part of route objects when you request directions using the `Directions.calculateDirections(options:completionHandler:)` method, setting the `includesSteps` option to `true` in the `RouteOptions` object that you pass into that method.
     
     - parameter json: A JSON object that conforms to the [route step](https://www.mapbox.com/api-documentation/#routestep-object) format described in the Directions API documentation.
     */
    @objc(initWithJSON:)
    public convenience init(json: [String: Any]) {
        let jsonDict = json["location"] as! JSONDictionary
        let location = CLLocationCoordinate2D(geoJSON: jsonDict["coordinates"] as! [Double])
        let type = jsonDict["type"] as! String
        self.init(location: location, type: type)
    }
    
    
   @objc public let location: CLLocationCoordinate2D
    
   @objc public let type: String
}
