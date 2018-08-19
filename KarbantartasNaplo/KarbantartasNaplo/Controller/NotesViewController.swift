//
//  NotesViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 08. 13..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DetailsViewControllerDelegate, ErrorViewDelegate {
    //MARK: - Outlets
    @IBOutlet private weak var deleteBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var errorView: ErrorView!
    @IBOutlet private weak var notesTableView: UITableView!
    
    @IBOutlet private weak var errorViewTop: NSLayoutConstraint!
    
    //MARK: - Properties
    var device: Device!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()

        errorView.delegate = self
        
        notesTableView.dataSource = self
        notesTableView.delegate = self
        
        deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if errorViewTop.constant == 0 { hideErrorView() }
    }
    
    //MARK: - UITableViewDataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return device.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "notesTableViewCell") as! NotesTableViewCell
        cell.note = device.notes[indexPath.row]
        return cell
    }
    
    //MARK: - UITableViewDelegate functions
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return notesTableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Törlés") { action, rowIndexPath in
            NetworkManager.deleteNoteOfDevice(device: self.device, creationDate: self.device.notes[rowIndexPath.row].creationDate) { data, error in
                var errorMessage = "Kommunikációs hiba!"
                
                if data != nil {
                    do {
                        if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            if let message = jsonData["message"] as? String {
                                if message == "success" {
                                    self.device.removeNote(at: rowIndexPath.row)
                                    self.notesTableView.deleteRows(at: [rowIndexPath], with: .automatic)
                                    
                                    if self.device.notes.count == 0 {
                                        DispatchQueue.main.async {
                                            self.notesTableView.isEditing = false
                                            self.deleteBarButtonItem.title = "Törlés"
                                            self.deleteBarButtonItem.isEnabled = false
                                        }
                                    }
                                    
                                    errorMessage = ""
                                }
                            }
                        }
                    } catch { }
                }
                
                if errorMessage.isEmpty {
                    DispatchQueue.main.async { self.hideErrorView() }
                } else {
                    DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
                }
            }
        }
        return [deleteAction]
    }
    
    //MARK: - Actions
    @IBAction func deleteBarButtonItemAction(_ sender: UIBarButtonItem) {
        notesTableView.isEditing = !notesTableView.isEditing
        sender.title = notesTableView.isEditing ? "Kész" : "Törlés"
        notesTableView.reloadData()
    }
    
    //MARK: - Common functions
    private func showErrorView(withErrorMessage: String) {
        self.errorView.text = withErrorMessage
        self.errorViewTop.constant = 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - DetailsViewControllerDelegate function
    func deviceChanged() {
        notesTableView.reloadData()
        deleteBarButtonItem.isEnabled = device.notes.count > 0  //TODO:
    }
    
    //MARK: - ErrorViewDelegate function
    func hideErrorView() {
        self.errorViewTop.constant = -40
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { completion in
            self.errorView.text = ""
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
