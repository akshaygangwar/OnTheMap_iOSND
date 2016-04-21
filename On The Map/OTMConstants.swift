//
//  OTMConstants.swift
//  On The Map
//
//  Created by Akshay Gangwar on 21/04/16.
//  Copyright © 2016 Akshay Gangwar. All rights reserved.
//

import UIKit

// MARK: Constants
struct OTMConstants {
    // MARK: UIColors
    struct UIConstants {
        static let backgroundColor = UIColor(red: 237/255.0, green: 118/255.0, blue: 38/255.0, alpha: 1)
        static let buttonColor = UIColor(red: 231/255.0, green: 61/255.0, blue: 37/255.0, alpha: 1)
    }
    
    // MARK: Udacity URL
    struct UdacityConstants {
        static let UdacityURL = "https://www.udacity.com/api/session"
    }
    
    // MARK: Parse URL
    struct ParseConstants {
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"
        static let ParseStudentLocationMethodURL = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    // MARK: Parse Parameter Keys
    struct ParseParameterKeys {
        static let ApplicationID = "X-Parse-Application-Id"
        static let RESTAPIKey = "X-Parse-REST-API-Key"
        static let Limit = "limit"
    }
    // MARK: Parse Parameter Values
    struct ParseParameterValues {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let Limit = 100 // TODO: For testing purposes. Set to 100 before submission
    }
}
