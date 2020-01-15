//
//  DataCenter.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 08..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit
import Firebase

class DataCenter {
    static let shared = DataCenter()
    private(set) var devices = [Device]()
    private(set) var login: Login?
    private let db = Firestore.firestore()
    
    private init() { }
    
    func getDevices(completion: @escaping (Bool) -> Void) {
//        NetworkManager.loadDevices() { data, error in
//            if data == nil {
//                completion(false)
//                return
//            }
//
//            do {
//                self.devices = try JSONDecoder().decode([Device].self, from: data!)
//                completion(true)
//            } catch {
//                completion(false)
//            }
//        }
        
        db.collection("devices").addSnapshotListener { (querySnapshot, error) in
            self.devices = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore, \(e)")
                completion(false)
            } else {
                if let safeDocuments = querySnapshot?.documents {
                    for document in safeDocuments {
                        let data = document.data()
                        
                        let number = data["number"] as? Int
                        let id = data["id"] as? Int
                        let token = data["token"] as? String
                        let name = data["name"] as? String
                        
                        var itemNo = data["itemNo"] as? String
                        if itemNo != nil && itemNo == "null" { itemNo = nil }
                        
                        let operationTime = data["operationTime"] as? Int
                        let period = data["period"] as? Int
                        let lastService = data["lastService"] as? Int
                        let notes = data["notes"] as? [[String: Any]]
                        
                        var arrayOfNotes = [Note]()
                        if let safeNotes = notes {
                            for note in safeNotes {
                                let creationDate = note["creationDate"] as? Int
                                let comment = note["comment"] as? String
                                
                                if let safeCreationDate = creationDate, let safeComment = comment {
                                    let newNote = Note(creationDate: safeCreationDate, comment: safeComment)
                                    arrayOfNotes.append(newNote)
                                }
                            }
                        }
                        
                        if let safeNumber = number, let safeId = id, let safeToken = token, let safeName = name, let safePeriod = period, let safeLastService = lastService {
                            let newDevice = Device(number: safeNumber, id: safeId, token: safeToken, name: safeName, itemNo: itemNo, operationTime: operationTime, period: safePeriod, lastService: safeLastService, notes: arrayOfNotes)
                            self.devices.append(newDevice)
                        }
                    }
                }
                completion(true)
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
