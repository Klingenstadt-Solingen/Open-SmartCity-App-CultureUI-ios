//
//  OSCACultureAppDI+Config.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import Foundation
import OSCAEssentials

extension OSCACultureAppDI {
  /// centralized class where external properties from `Info.plist` are accessable
  public final class Config {
    public private(set) lazy var defaultGeoPoint: (latitude: Double,longitude: Double) = {
      return Environment.defaultGeoPoint
    }()// end lazy var defaultGeoPoint
    
    public var defaultGeoPointStruct: OSCAGeoPoint { return Environment.defaultGeoPointStruct }
    
    public private(set) lazy var parseAPIKey: String = {
      return Environment.parseAPIKey
    }()// end lazy var parseAPIKey
    
    public private(set) lazy var parseAPIBaseURL: String = {
      return Environment.parseAPIRootURL
    }()// end lazy var parseAPIBaseURL
    
    public private(set) lazy var parseApplicationID: String = {
      return Environment.parseAPIApplicationID
    }()// end lazy var parseApplicationID
    
    public private(set) lazy var parseAPIKeyDev: String = {
      return Environment.parseAPIKeyDev
    }()// end lazy var parseAPIKeyDev
    
    public private(set) lazy var parseAPIBaseURLDev: String = {
      return Environment.parseAPIRootURLDev
    }()// end lazy var parseAPIBaseURLDev
    
    public private(set) lazy var parseApplicationIDDev: String = {
      return Environment.parseAPIApplicationIDDev
    }()// end lazy var parseApplicationIDDev
    
    public private(set) lazy var imagesBaseURL: String = {
      return Environment.imageAPIRootURL
    }()// end lazy var imagesBaseURL
    
    // MARK: -LaunchScreen
    /**
     title of app's launch screen
     */
    public private(set) lazy var launchScreenTitle: String = {
      return Environment.launchSreenTitle
    }()// end lazy var launchSreenTitle
    /**
     name of app's launch screen image
     */
    public private(set) lazy var launchScreenImageName: String = {
      return Environment.launchScreenImageName
    }()// end lazy var launchScreenImageName
    
    // MARK: -SplashScreen
    /**
     filename of the json-file without suffix
     */
    public private(set) lazy var splashAnimationName: String = {
      return Environment.splashAnimationName
    }() // end lazy var splashAnimationName
    /**
     animation speed 1.0 <=> 100%
     */
    public private(set) lazy var splashAnimationSpeed: Float = 1.5
    
    public private(set) lazy var infoPlistsData: Data = {
      return Environment.apiData
    }() ?? Data() // end lazy var homeTabItems
    
    // MARK: - Device
    
    public private(set) lazy var deviceUUID: String = {
      return NSUUID().uuidString
    }()
    
    // MARK: - Deeplink
    
    public private(set) lazy var deeplinkScheme: String = {
      return Environment.deeplinkScheme
    }()
    
    public init() {}
  }// end final class AppConfig
}// end extension

// - MARK: Equatable conformance
extension OSCACultureAppDI.Config: Equatable{
  static func == (lhs: OSCACultureAppDI.Config, rhs: OSCACultureAppDI.Config) -> Bool {
    let defaultGeoPointEqual: Bool = lhs.defaultGeoPoint == rhs.defaultGeoPoint
    let defaultGeoPointStructEqual: Bool = lhs.defaultGeoPointStruct == rhs.defaultGeoPointStruct
    let parseAPIKeyEqual: Bool = lhs.parseAPIKey == rhs.parseAPIKey
    let parseAPIBaseURLEqual: Bool = lhs.parseAPIBaseURL == rhs.parseAPIBaseURL
    let parseApplicationIDEqual: Bool = lhs.parseApplicationID == rhs.parseApplicationID
    let parseAPIKeyDevEqual: Bool = lhs.parseAPIKeyDev == rhs.parseAPIKeyDev
    let parseAPIBaseURLDevEqual: Bool = lhs.parseAPIBaseURLDev == rhs.parseAPIBaseURLDev
    let parseApplicationIDDevEqual: Bool = lhs.parseApplicationIDDev == rhs.parseApplicationIDDev
    let imagesBaseURLEqual: Bool = lhs.imagesBaseURL == rhs.imagesBaseURL
    let launchScreenTitleEqual: Bool = lhs.launchScreenTitle == rhs.launchScreenTitle
    let launchScreenImageNameEqual: Bool = lhs.launchScreenImageName == rhs.launchScreenImageName
    let splashAnimationNameEqual: Bool = lhs.splashAnimationName == rhs.splashAnimationName
    let splashAnimationSpeedEqual: Bool = lhs.splashAnimationSpeed == rhs.splashAnimationSpeed
    let infoPlistsDataEqual: Bool = lhs.infoPlistsData == rhs.infoPlistsData
    let deviceUUIDEqual: Bool = lhs.deviceUUID == rhs.deviceUUID
    return defaultGeoPointEqual &&
    defaultGeoPointStructEqual &&
    parseAPIKeyEqual &&
    parseAPIBaseURLEqual &&
    parseApplicationIDEqual &&
    parseAPIKeyDevEqual &&
    parseAPIBaseURLDevEqual &&
    parseApplicationIDDevEqual &&
    imagesBaseURLEqual &&
    launchScreenTitleEqual &&
    launchScreenImageNameEqual &&
    splashAnimationNameEqual &&
    splashAnimationSpeedEqual &&
    infoPlistsDataEqual &&
    deviceUUIDEqual
  }// end public static func ==
  
  
}// end final class Config

extension OSCACultureAppDI.Config: OSCAAppConfig {}
