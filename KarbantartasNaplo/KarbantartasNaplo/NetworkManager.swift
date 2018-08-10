//
//  NetworkManager.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 07..
//  Copyright © 2018. Daniel. All rights reserved.
//

import Alamofire

class NetworkManager {
    //MARK: - Properties
    private static var manager: SessionManager?
    
    //MARK: - GET requests
    static func loadDevices(completion: @escaping (Data?, Error?) -> Void) {
        sendRequest(to: "https://5b763aee-2eec-4c50-bc02-b4ad32d58a80.mock.pstmn.io/getDevices", method: .get, parameters: nil, headers: nil, completion: completion)
    }
    
    //MARK: - PUT requests
    static func serviceDevice(device: Device, completion: @escaping (Data?, Error?) -> Void) {
        let parameters: [String: Any] = [
            "number": device.number,
            "id": device.id,
            "token": device.token,
            "name": device.name,
            "itemNo": device.itemNo ?? NSNull(),
            "operationTime": 0,
            "period": device.period,
            "lastService": Int(Date().timeIntervalSince1970)
        ]
        
        sendRequest(to: "https://5b763aee-2eec-4c50-bc02-b4ad32d58a80.mock.pstmn.io/updateDevice", method: .put, parameters: parameters, headers: nil, completion: completion)
    }
    
    //MARK: - POST requests
    static func login(email: String, password: String, completion: @escaping (Data?, Error?) -> Void) {
        let headers = [
            "hardwareId": UIDevice.current.identifierForVendor!.uuidString,
            "os": "iOS",
            "osVersion": UIDevice.current.systemVersion
        ]
        let parameters = [
            "email": email,
            "password": password
        ]
        
        sendRequest(to: "http://138.197.187.213/itacademy/login", method: .post, parameters: parameters, headers: headers, completion: completion)
    }
    
    static func signUp(email: String, password: String, passwordAgain: String, completion: @escaping (Data?, Error?) -> Void) {
        let headers = [
            "hardwareId": UIDevice.current.identifierForVendor!.uuidString,
            "os": "iOS",
            "osVersion": UIDevice.current.systemVersion
        ]
        let parameters = [
            "email": email,
            "password": password,
            "repassword": passwordAgain
        ]
        
        sendRequest(to: "http://138.197.187.213/itacademy/register", method: .post, parameters: parameters, headers: headers, completion: completion)
    }
    
    //MARK: - Send request function
    private static func sendRequest(to url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?, completion: @escaping (Data?, Error?) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        manager = Alamofire.SessionManager(configuration: configuration)
        
        manager!.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
            guard response.result.isSuccess, let value = response.result.value else {
                completion(nil, response.result.error)
                return
            }
            
            completion(value, nil)
        }
    }
}
