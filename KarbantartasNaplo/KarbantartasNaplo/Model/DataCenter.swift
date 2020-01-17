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
    private(set) var user = User.nobody
    private let db = Firestore.firestore()
    
    private init() { }
    
    func getDevices(completion: @escaping (Bool) -> Void) {
        db.collection("devices").order(by: "number").getDocuments { (querySnapshot, error) in
            self.devices = []

            if let e = error {
                print("Retrieving data failed, \(e)")
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
                            arrayOfNotes.sort(by: { $0.creationDate > $1.creationDate })
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
    
    func serviceDevice(id: Int, completion: @escaping (Bool) -> Void) {
        let device = devices.first(where: { $0.id == id })!
        let comment = """
        Üzemidő nullázása.
        Előző karbantartás óta eltelt üzemidő: \(device.operationTime != nil ? String(device.operationTime!) : "?") h.
        Karbantartási periódus: \(device.period) h.
        """
        
        let nowAsInt = Int(Date().timeIntervalSince1970)
        let newNote: [String: Any] = [
            "creationDate": nowAsInt,
            "comment": comment
        ]
        
        db.collection("devices").document(String(id)).updateData([
            "operationTime": 0,
            "lastService": nowAsInt,
            "notes": FieldValue.arrayUnion([newNote])
        ]) { error in
            if let e = error {
                print("Servicing device failed, \(e)")
                completion(false)
            } else {
                device.setOperationTimeToZero()
                device.addNote(date: Date(timeIntervalSince1970: TimeInterval(nowAsInt)), comment: comment)
                completion(true)
            }
        }
    }
    
    func setDevicePeriod(id: Int, newPeriod: Int, completion: @escaping (Bool) -> Void) {
        let device = devices.first(where: { $0.id == id })!
        let comment = "Karbantartási periódus módosítása: \(device.period) h -> \(newPeriod) h."
        
        let nowAsInt = Int(Date().timeIntervalSince1970)
        let newNote: [String: Any] = [
            "creationDate": nowAsInt,
            "comment": comment
        ]
        
        db.collection("devices").document(String(id)).updateData([
            "period": newPeriod,
            "notes": FieldValue.arrayUnion([newNote])
        ]) { error in
            if let e = error {
                print("Setting device period failed, \(e)")
                completion(false)
            } else {
                device.setPeriod(to: newPeriod)
                device.addNote(date: Date(timeIntervalSince1970: TimeInterval(nowAsInt)), comment: comment)
                completion(true)
            }
        }
    }
    
    func addNoteToDevice(id: Int, comment: String, completion: @escaping (Bool) -> Void) {
        let device = devices.first(where: { $0.id == id })!
        
        let nowAsInt = Int(Date().timeIntervalSince1970)
        let newNote: [String: Any] = [
            "creationDate": nowAsInt,
            "comment": comment
        ]
        
        db.collection("devices").document(String(id)).updateData([
            "notes": FieldValue.arrayUnion([newNote])
        ]) { error in
            if let e = error {
                print("Adding note to device failed, \(e)")
                completion(false)
            } else {
                device.addNote(date: Date(timeIntervalSince1970: TimeInterval(nowAsInt)), comment: comment)
                completion(true)
            }
        }
    }
    
    func updateNoteOfDevice(id: Int, creationDate: Int, comment: String, completion: @escaping (Bool) -> Void) {
        let device = devices.first(where: { $0.id == id })!
        let documentReference = db.collection("devices").document(String(id))
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let documentSnapshot: DocumentSnapshot
            do {
                try documentSnapshot = transaction.getDocument(documentReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var notes = documentSnapshot.data()?["notes"] as? [[String: Any]] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve notes from snapshot \(documentSnapshot)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            guard let index = notes.firstIndex(where: { $0["creationDate"] as! Int == creationDate }) else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Requested note doesn't exist in snapshot \(documentSnapshot)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            notes[index]["comment"] = comment
            
            transaction.updateData(["notes": notes], forDocument: documentReference)
            return nil
        }) { (object, error) in
            if let e = error {
                print("Updating note of device failed, \(e)")
                completion(false)
            } else {
                device.notes.first(where: { $0.creationDate == creationDate })!.setComment(to: comment)
                completion(true)
            }
        }
    }
    
    func deleteNotesOfDevice(id: Int, creationDates: [Int], completion: @escaping (Bool) -> Void) {
        let documentReference = db.collection("devices").document(String(id))
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let documentSnapshot: DocumentSnapshot
            do {
                try documentSnapshot = transaction.getDocument(documentReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var notes = documentSnapshot.data()?["notes"] as? [[String: Any]] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve notes from snapshot \(documentSnapshot)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            notes.removeAll(where: { creationDates.contains($0["creationDate"] as! Int)} )
            
            transaction.updateData(["notes": notes], forDocument: documentReference)
            return nil
        }) { (object, error) in
            if let e = error {
                print("Deleting notes of device failed, \(e)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let e = error {
                print("Login failed, \(e)")
                completion(false, "Sikertelen bejelentkezés!")
            } else {
                if authResult?.user.email == "admin@admin.com" {
                    self.user = .admin
                } else {
                    self.user = .boss
                }
                completion(true, nil)
            }
        }
    }
    
    func logoutUser(completion: @escaping (Bool, String?) -> Void) {
        do {
            try Auth.auth().signOut()
            user = .nobody
            completion(true, nil)
        } catch let error as NSError {
            print("Logout failed, \(error)")
            completion(false, "Sikertelen kijelentkezés!")
        }
    }
    
    func signupUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let e = error {
                print("Signup failed, \(e)")
                completion(false, "Sikertelen regisztráció!")
            } else {
                completion(true, nil)
            }
        }
    }
}
