//
//  NotesViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 08. 13..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var deleteBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var errorView: ErrorView!
    @IBOutlet private weak var notesTableView: UITableView!
    @IBOutlet private weak var addButton: MyFloatingButton!
    @IBOutlet private weak var deleteCancelButton: UIButton!
    
    @IBOutlet private weak var errorViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var addButtonTrailing: NSLayoutConstraint!
    @IBOutlet private weak var deleteViewBottom: NSLayoutConstraint!
    
    //MARK: - Properties
    private var selectedNote: Note?
    private var deleteInProgress = false
    var device: Device!
    
    private var deletedNotes = [Note]() {
        didSet {
            deleteCancelButton.titleLabel?.font = deletedNotes.count > 0 ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17)
            deleteCancelButton.isEnabled = deletedNotes.count > 0
        }
    }
    
    private var isNotesTableViewEditing = false {
        didSet {
            if isNotesTableViewEditing {
                navigationItem.setHidesBackButton(true, animated: true)
                deleteBarButtonItem.title = "Kész"
                notesTableView.setEditing(true, animated: true)
                
                addButtonTrailing.constant = 75
                deleteViewBottom.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
                deleteBarButtonItem.title = "Törlés"
                notesTableView.setEditing(false, animated: true)
                
                addButtonTrailing.constant = -20
                deleteViewBottom.constant = 50
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                if !deleteInProgress {
                    var creationDates = [Int]()
                    for note in deletedNotes {
                        creationDates.append(note.creationDate)
                    }
                    
                    if creationDates.count > 0 {
                        deleteInProgress = true
                        
                        NetworkManager.deleteNotesOfDevice(device: self.device, creationDates: creationDates) { data, error in
                            var errorMessage = "Kommunikációs hiba!"
                            
                            if data != nil {
                                do {
                                    if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                        if let message = jsonData["message"] as? String {
                                            if message == "success" {
                                                errorMessage = ""
                                            }
                                        }
                                    }
                                } catch { }
                            }
                            
                            if errorMessage.isEmpty {
                                self.deletedNotes.removeAll()
                                DispatchQueue.main.async { self.hideErrorView() }
                            } else {
                                DispatchQueue.main.async {
                                    self.restoreDeletedNotes()
                                    self.showErrorView(withErrorMessage: errorMessage)
                                }
                            }
                            
                            self.deleteInProgress = false
                            DispatchQueue.main.async { self.navigationItem.setHidesBackButton(false, animated: true) }
                        }
                    } else {
                        self.navigationItem.setHidesBackButton(false, animated: true)
                    }
                }
            }
        }
    }
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()

        errorView.delegate = self
        notesTableView.dataSource = self
        notesTableView.delegate = self
        
        errorView.alpha = 0
        deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
        addButton.backgroundColor = Constants.color
        addButton.isEnabled = true  //TODO:
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if errorViewBottom.constant == 0 { hideErrorView() }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if isNotesTableViewEditing { notesTableView.reloadData() }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditNoteViewController {
            vc.delegate = self
            vc.note = selectedNote
        }
    }
    
    //MARK: - Actions
    @IBAction func addButtonTouchUpInside(_ sender: UIButton) {
        selectedNote = nil
        performSegue(withIdentifier: "showEditNoteSegue", sender: nil)
    }
    
    @IBAction func deleteBarButtonItemAction(_ sender: UIBarButtonItem) {
        isNotesTableViewEditing = !isNotesTableViewEditing
    }
    
    @IBAction func deleteAllButtonTouchUpInside(_ sender: UIButton) {
        if device.notes.count == 0 { return }
        
        for note in device.notes {
            deletedNotes.append(note)
        }
        device.removeAllNote()
        notesTableView.reloadData()
    }
    
    @IBAction func deleteCancelButtonTouchUpInside(_ sender: UIButton) {
        restoreDeletedNotes()
        isNotesTableViewEditing = false
    }
    
    //MARK: - Common functions
    private func restoreDeletedNotes() {
        for note in deletedNotes {
            device.appendNote(note)
        }
        device.sortNotes()
        deviceChanged()
        deletedNotes.removeAll()
    }
    
    private func showErrorView(withErrorMessage: String) {
        errorView.text = withErrorMessage
        errorView.alpha = 1
        errorViewBottom.constant = 40
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - Extensions
extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return device.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "notesTableViewCell") as! NotesTableViewCell
        cell.note = device.notes[indexPath.row]
        return cell
    }
}

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isNotesTableViewEditing
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Törlés") { action, rowIndexPath in
            self.deletedNotes.append(self.device.notes[rowIndexPath.row])
            self.device.removeNote(at: rowIndexPath.row)
            self.notesTableView.deleteRows(at: [rowIndexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* If TableViewCell Selection is None, modally presented segue must be executed this way,
         otherwise destination VC opens for the second tap most of the times. */
        selectedNote = device.notes[indexPath.row]
        DispatchQueue.main.async { self.performSegue(withIdentifier: "showEditNoteSegue", sender: nil) }
    }
}

extension NotesViewController: DetailsViewControllerDelegate {
    func deviceChanged() {
        notesTableView.reloadData()
        deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
    }
}

extension NotesViewController: EditNoteViewControllerDelegate {
    func addNote(date: Date, comment: String) {
        NetworkManager.addNoteToDevice(device: device, creationDate: Int(date.timeIntervalSince1970), comment: comment) { data, error in
            var errorMessage = "Kommunikációs hiba!"
            
            if data != nil {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let message = jsonData["message"] as? String {
                            if message == "success" {
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage.isEmpty {
                self.device.addNote(date: date, comment: comment)
                DispatchQueue.main.async {
                    self.deviceChanged()
                    self.hideErrorView()
                }
            } else {
                DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
            }
        }
    }
    
    func noteChanged(creationDate: Int, comment: String) {
        NetworkManager.updateNoteOfDevice(device: device, creationDate: creationDate, comment: comment) { data, error in
            var errorMessage = "Kommunikációs hiba!"
            
            if data != nil {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let message = jsonData["message"] as? String {
                            if message == "success" {
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage.isEmpty {
                self.device.notes.first(where: { $0.creationDate == creationDate })?.setComment(comment: comment)
                DispatchQueue.main.async {
                    self.notesTableView.reloadData()
                    self.hideErrorView()
                }
            } else {
                DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
            }
        }
    }
}

extension NotesViewController: ErrorViewDelegate {
    func hideErrorView() {
        errorViewBottom.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { completion in
            self.errorView.text = ""
            self.errorView.alpha = 0
        }
    }
}
