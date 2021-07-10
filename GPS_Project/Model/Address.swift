//
//  Address.swift
//  GPS_Project
//
//  Created by André Yamasaki on 10/07/21.
//

import Foundation
import Contacts
import CoreLocation

struct Address {
    var name: String
    var placeMark: CLPlacemark
    var postalAddress: CNPostalAddress
    
    init(name: String, placeMark: CLPlacemark, postalAddress: CNPostalAddress) {
        self.name = name
        self.placeMark = placeMark
        self.postalAddress = postalAddress
    }
}
