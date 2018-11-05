//
//  DataCenter.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 08..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class DataCenter {
    static let shared = DataCenter()
    private(set) var devices = [Device]()
    private(set) var login: Login?
    
    private init() { }
    
    func getDevices(completion: @escaping (Bool) -> Void) {
        NetworkManager.loadDevices() { data, error in
            if data == nil {
                completion(false)
                return
            }
            
            do {
                self.devices = try JSONDecoder().decode([Device].self, from: data!)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        NetworkManager.login(email: email, password: password) { data, error in
            if data == nil {
                completion(false, "Kommunikációs hiba!")
                return
            }
            
            do {
                self.login = try JSONDecoder().decode(Login.self, from: data!)
                completion(true, nil)
            } catch {
                completion(false, "Érvénytelen Email vagy Jelszó!")
            }
        }
    }
    
    func signUpUser(email: String, password: String, passwordAgain: String, completion: @escaping (Bool, String?) -> Void) {
        NetworkManager.signUp(email: email, password: password, passwordAgain: passwordAgain) { data, error in
            if data == nil {
                completion(false, "An error occured!")
                return
            }
            
            do {
                if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    if let errorMessage = jsonData["message"] as? String {
                        completion(false, errorMessage)
                    } else {
                        completion(true, nil)
                    }
                } else {
                    completion(false, "An error occured!")
                }
            } catch {
                completion(false, "An error occured!")
            }
        }
    }
}
