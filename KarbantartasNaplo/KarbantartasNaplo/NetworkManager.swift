//
//  NetworkManager.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 07..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
    static func login(email: String, password: String, completion: @escaping (Data?, Error?) -> Void) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "hardwareId": UIDevice.current.identifierForVendor!.uuidString,
            "os": "iOS",
            "osVersion": UIDevice.current.systemVersion
        ]
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request("http://138.197.187.213/itacademy/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
            
        }
    }
}
