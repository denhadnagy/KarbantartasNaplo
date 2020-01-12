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
    
    @IBOutlet private weak var errorViewLeading: NSLayoutConstraint!
    @IBOutlet private weak var errorViewWidth: NSLayoutConstraint!
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
        
        deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
        addButton.backgroundColor = Constants.color
        addButton.isEnabled = true  //TODO:
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        errorViewWidth.constant = UIScreen.main.bounds.width - 40
        if errorViewLeading.constant != 0 { errorViewLeading.constant = -UIScreen.main.bounds.width + 20 }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if errorViewLeading.constant != 0 { hideErrorView() }
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
        device.removeAllNotes()
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
}

//MARK: - Extensions: UITableView DataSource & Delegate
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Törlés") { (contextualAction, sourceView, success) in
            self.deletedNotes.append(self.device.notes[indexPath.row])
            self.device.removeNote(at: indexPath.row)
            self.notesTableView.deleteRows(at: [indexPath], with: .automatic)
            success(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* If TableViewCell Selection is None, modally presented segue must be executed this way,
         otherwise destination VC opens for the second tap most of the times:
         
         DispatchQueue.main.async { self.performSegue(withIdentifier: "showEditNoteSegue", sender: nil) } */
        selectedNote = device.notes[indexPath.row]
        performSegue(withIdentifier: "showEditNoteSegue", sender: nil)
    }
}

//MARK: - Extension: DetailsViewControllerDelegate
extension NotesViewController: DetailsViewControllerDelegate {
    func deviceChanged() {
        notesTableView.reloadData()
        deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
    }
}

//MARK: - Extension: EditNoteViewControllerDelegate
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
                self.device.notes.first(where: { $0.creationDate == creationDate })?.setComment(to: comment)
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

//MARK: - Extension: ErrorViewDelegate
extension NotesViewController: ErrorViewDelegate {
    func showErrorView(withErrorMessage: String) {
        errorView.text = withErrorMessage
        errorViewLeading.constant = -UIScreen.main.bounds.width + 20
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
    }
    
    func hideErrorView() {
        errorViewLeading.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) { completion in
            self.errorView.text = ""
        }
    }
}
