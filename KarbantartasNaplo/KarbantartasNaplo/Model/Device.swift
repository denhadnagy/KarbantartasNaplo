//
//  Device.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 11..
//  Copyright © 2018. Daniel. All rights reserved.
//

import Foundation

class Device: Codable {
    private(set) var number = 0
    private(set) var id = 0
    private(set) var token = ""
    private(set) var name = ""
    private(set) var itemNo: String?
    private(set) var operationTime: Int?
    private(set) var period = 0
    private(set) var lastService = 0
    private(set) var notes = [Note]()
    
    var rate: Double? {
        get {
            if operationTime == nil || period == 0 { return nil }
            return min(round(Double(operationTime!) / Double(period) * 100.0), 100.0)
        }
    }
    
    var severity: Severity {
        get {
            if rate == nil { return .undefined }
            
            switch rate! {
            case let r where r < 80: return .ok
            case let r where r < 90: return .soon
            case let r where r < 100: return .actual
            default: return .urgent
            }
        }
    }
    
    func setOperationTimeToZero() {
        operationTime = 0
        lastService = Int(Date().timeIntervalSince1970)
    }
    
    func setPeriod(period: Int) {
        self.period = period
    }
    
    func appendNote(_ note: Note) {
        notes.append(note)
    }
    
    func addNote(date: Date, comment: String) {
        notes.insert(Note(creationDate: Int(date.timeIntervalSince1970), comment: comment), at: 0)
    }
    
    func removeNote(at: Int) {
        notes.remove(at: at)
    }
    
    func removeAllNote() {
        notes.removeAll()
    }
    
    func sortNotes() {
        notes = notes.sorted { $0.creationDate > $1.creationDate }
    }
}
