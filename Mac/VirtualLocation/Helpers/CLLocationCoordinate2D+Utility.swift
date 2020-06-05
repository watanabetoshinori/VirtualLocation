//
//  CLLocationCoordinate2D+Utility.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import MapKit

/// CLLocationCoordinate2Dの拡張
extension CLLocationCoordinate2D {

    var isInvalid: Bool {
        latitude == kCLLocationCoordinate2DInvalid.latitude
            && longitude == kCLLocationCoordinate2DInvalid.longitude
    }

}
