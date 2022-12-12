import Polyline

/**
 A `RouteEvent` object defines a single leg of a route between two waypoints. If the overall route has only two waypoints, it has a single `RouteEvent` object that covers the entire route. The route leg object includes information about the leg, such as its name, distance, and expected travel time. Depending on the criteria used to calculate the route, the route leg object may also include detailed turn-by-turn instructions.
 
 You do not create instances of this class directly. Instead, you receive route leg objects as part of route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBRouteEvent)
open class RouteEvent: NSObject, NSSecureCoding {
    // MARK: Creating a Leg
    @objc internal init(_id: String, type: Int, address: String, location: RouteEventLocation) {
        self._id = _id
        self.type = type
        self.address = address
        self.location = location

    }

    @objc(initWithJSON:)
    public convenience init(json: [String: Any]) {
        let _id = json["_id"] as! String
        let type = json["type"] as! Int
        let address = json["address"] as! String
        let location = RouteEventLocation.init(json: json)
        self.init(_id: _id, type: type, address: address, location: location)
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let decodedID = decoder.decodeObject(of: NSString.self, forKey: "_id") as String? else {
            return nil
        }
        _id = decodedID
        
        type = decoder.decodeInteger(forKey: "type")
        
        guard let decodedAddress = decoder.decodeObject(of: NSString.self, forKey: "address") as String? else {
            return nil
        }
        address = decodedAddress
        
        guard let decodedLocation = decoder.decodeObject(of:
                RouteEventLocation.self, forKey: "location") else {
            return nil
        }
        location = decodedLocation
    }
    
    @objc public static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(_id, forKey: "_id")
        coder.encode(type, forKey: "type")
        coder.encode(address, forKey: "address")
        coder.encode(location, forKey: "location")
    }
    
    // MARK: Getting the Leg Geometry

    @objc public let _id: String
    
    @objc public let type: Int
    
    @objc public let address: String
    
    @objc open override var description: String {
        return address
    }
    
    @objc public let location: RouteEventLocation
}
