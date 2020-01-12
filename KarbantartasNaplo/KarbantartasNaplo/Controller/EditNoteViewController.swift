//
//  EditNoteViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 10. 08..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

protocol EditNoteViewControllerDelegate {
    func addNote(date: Date, comment: String)
    func noteChanged(creationDate: Int, comment: String)
}

class EditNoteViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var creationTimeLabel: UILabel!
    @IBOutlet private weak var okButton: MyFloatingButton!
    @IBOutlet private weak var cancelButton: MyFloatingButton!
    @IBOutlet private weak var commentTextView: UITextView!
    
    @IBOutlet private weak var commentTextViewBottom: NSLayoutConstraint!
    
    //MARK: - Properties
    private var initialComment = ""
    var delegate: EditNoteViewControllerDelegate?
    var note: Note?
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        creationDateLabel.text = "Új bejegyzés"
        creationTimeLabel.text = ""
        if note != nil {
            let creationDate = Date(timeIntervalSince1970: TimeInterval(note!.creationDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            
            creationDateLabel.text = dateFormatter.string(from: creationDate)
            dateFormatter.dateFormat = "HH:mm"
            creationTimeLabel.text = dateFormatter.string(from: creationDate)
            commentTextView.text = note!.comment
            initialComment = note!.comment
        }
        
        okButton.backgroundColor = Constants.color
        cancelButton.backgroundColor = Constants.color
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        commentTextView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let location = commentTextView.text.count - 1
        commentTextView.scrollRangeToVisible(NSMakeRange(location, 1))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        var keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        keyboardFrame = view.convert(keyboardFrame, from: view.window)
        commentTextViewBottom.constant = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        commentTextViewBottom.constant = 10
    }
    
    //MARK: - Actions
    @IBAction func okButtonTouchUpInside(_ sender: UIButton) {
        if note != nil {
            delegate?.noteChanged(creationDate: note!.creationDate, comment: commentTextView.text)
        } else {
            delegate?.addNote(date: Date(), comment: commentTextView.text)
        }
        close()
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        close()
    }
    
    //MARK: - Common functions
    private func close() {
        commentTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Extension: UITextViewDelegate
extension EditNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == initialComment || textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            okButton.isEnabled = false
            okButton.alpha = 0.6
        } else {
            okButton.isEnabled = true
            okButton.alpha = 1
        }
    }
}
