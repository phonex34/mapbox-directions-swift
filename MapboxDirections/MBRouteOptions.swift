/// For directions by automobile.
public let MBDirectionsProfileIdentifierAutomobile = "mapbox/driving"

/// For directions by bicycle.
public let MBDirectionsProfileIdentifierCycling = "mapbox/cycling"

/// For walking or hiking directions.
public let MBDirectionsProfileIdentifierWalking = "mapbox/walking"

@objc(MBRouteShapeFormat)
public enum RouteShapeFormat: UInt, CustomStringConvertible {
    /// [GeoJSON](http://geojson.org/) format.
    case GeoJSON
    /// [Encoded polyline algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm) format.
    case Polyline
    
    public init?(description: String) {
        let format: RouteShapeFormat
        switch description {
        case "geojson":
            format = .GeoJSON
        case "polyline":
            format = .Polyline
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .GeoJSON:
            return "geojson"
        case .Polyline:
            return "polyline"
        }
    }
}

@objc(MBRouteShapeResolution)
public enum RouteShapeResolution: UInt, CustomStringConvertible {
    case None
    case Low
    case Full
    
    public init?(description: String) {
        let granularity: RouteShapeResolution
        switch description {
        case "false":
            granularity = .None
        case "simplified":
            granularity = .Low
        case "full":
            granularity = .Full
        default:
            return nil
        }
        self.init(rawValue: granularity.rawValue)
    }
    
    public var description: String {
        switch self {
        case .None:
            return "false"
        case .Low:
            return "simplified"
        case .Full:
            return "full"
        }
    }
}

@objc(MBRouteOptions)
public class RouteOptions: NSObject {
    // MARK: Creating a Directions Options Object
    
    public init(waypoints: [Waypoint], profileIdentifier: String? = nil) {
        assert(waypoints.count >= 2, "A route requires at least a source and destination.")
        assert(waypoints.count <= 25, "A route may not have more than 25 waypoints.")
        
        self.waypoints = waypoints
        self.profileIdentifier = profileIdentifier ?? MBDirectionsProfileIdentifierAutomobile
        self.allowUTurnAtWaypoint = self.profileIdentifier != MBDirectionsProfileIdentifierAutomobile
    }
    
    public convenience init(locations: [CLLocation], profileIdentifier: String? = nil) {
        let waypoints = locations.map { Waypoint(location: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: String? = nil) {
        let waypoints = coordinates.map { Waypoint(coordinate: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    // MARK: Specifying the Path of the Route
    
    public var waypoints: [Waypoint]
    
    /**
     A Boolean value that indicates whether a returned route may require a U-turn at an intermediate waypoint.
     
     If the value of this property is `true`, a returned route may require a U-turn at an intermediate waypoint. If the value of this property is `false`, all returned routes may continue straight ahead or turn but may not U-turn at an intermediate waypoint. This property has no effect if only two waypoints are specified. The default value of this property is `false` when the profile identifier is `MBDirectionsProfileIdentifierAutomobile` and `true` otherwise.
     */
    public var allowUTurnAtWaypoint: Bool
    
    // MARK: Specifying Transportation Options
    
    public var profileIdentifier: String
    
    // MARK: Specifying the Response Format
    
    public var includeAlternativeRoutes = false
    public var includeSteps = false
    
    /**
     Format of the data from which the shapes of the returned route and its steps are derived.
     
     This property has no effect on the returned shape objects, although the choice of format can significantly affect the size of the underlying HTTP response.
     */
    public var shapeFormat = RouteShapeFormat.Polyline
    
    /**
     Resolution of the shape of the returned route.
     
     This property has no effect on the shape of the returned route’s steps.
     */
    public var routeShapeResolution = RouteShapeResolution.Low
    
    // MARK: Constructing the Request URL
    
    /**
     An array of geocoding query strings to include in the request URL.
     */
    internal var queries: [String] {
        return waypoints.map { "\($0.coordinate.longitude),\($0.coordinate.latitude)" }
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [NSURLQueryItem] {
        var params: [NSURLQueryItem] = [
            NSURLQueryItem(name: "alternatives", value: String(includeAlternativeRoutes)),
            NSURLQueryItem(name: "geometries", value: String(shapeFormat)),
            NSURLQueryItem(name: "overview", value: String(routeShapeResolution)),
            NSURLQueryItem(name: "steps", value: String(includeSteps)),
            NSURLQueryItem(name: "continue_straight", value: String(!allowUTurnAtWaypoint)),
        ]
        
        // Include headings and heading accuracies if any waypoint has a nonnegative heading.
        if !waypoints.filter({ $0.heading >= 0 }).isEmpty {
            let headings = waypoints.map { $0.headingDescription }.joinWithSeparator(";")
            params.append(NSURLQueryItem(name: "bearings", value: headings))
        }
        
        // Include location accuracies if any waypoint has a nonnegative coordinate accuracy.
        if !waypoints.filter({ $0.coordinateAccuracy >= 0 }).isEmpty {
            let accuracies = waypoints.map {
                $0.coordinateAccuracy >= 0 ? String($0.coordinateAccuracy) : "unlimited"
            }.joinWithSeparator(";")
            params.append(NSURLQueryItem(name: "radiuses", value: accuracies))
        }
        
        return params
    }
}
