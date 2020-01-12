//
//  Device.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 11..
//  Copyright © 2018. Daniel. All rights reserved.
//

import Foundation

class Device: Codable {
    let number: Int
    let id: Int
    let token: String
    let name: String
    private(set) var itemNo: String?
    private(set) var operationTime: Int?
    private(set) var period = 0
    private(set) var lastService = 0
    private(set) var notes = [Note]()
    
    var rate: Double? {
        if operationTime == nil || period == 0 { return nil }
        return min(round(Double(operationTime!) / Double(period) * 100.0), 100.0)
    }
    
    var severity: Severity {
        if rate == nil { return .undefined }
        
        switch rate! {
        case ..<80: return .ok
        case ..<90: return .soon
        case ..<100: return .actual
        default: return .urgent
        }
    }
    
    func setOperationTimeToZero() {
        operationTime = 0
        lastService = Int(Date().timeIntervalSince1970)
    }
    
    func setPeriod(to period: Int) {
        self.period = period
    }
    
    func appendNote(_ note: Note) {
        notes.append(note)
    }
    
    func addNote(date: Date, comment: String) {
        notes.insert(Note(creationDate: Int(date.timeIntervalSince1970), comment: comment), at: 0)
    }
    
    func removeNote(at index: Int) {
        notes.remove(at: index)
    }
    
    func removeAllNotes() {
        notes.removeAll()
    }
    
    func sortNotes() {
        notes = notes.sorted { $0.creationDate > $1.creationDate }
    }
}
