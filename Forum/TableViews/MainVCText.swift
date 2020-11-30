//
//  MainVCText.swift
//  Forum
//
//  Created by Oscar on 2020/11/30.
//

import UIKit

extension MainVC: UITextViewDelegate {
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if scene == .floors {
            let height = (sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
            var time: TimeInterval = 0
            (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
            bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 16
            bottomSpace.constant = height
            UIView.animate(withDuration: time) {
                self.view.layoutIfNeeded()
            }
            completion: { (t) in
                if let dd = self.d as? Floor.Manager {
                    self.tableView.scrollToRow(at: IndexPath(row: (dd.data.firstIndex(where: {$0.id == self.floor}) ?? -1) + 1, section: 0), at: .none, animated: true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if scene == .floors {
            var time: TimeInterval = 0
            (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
            bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 20 + 16
            let delta = bottomSpace.constant
            bottomSpace.constant = 0
            UIView.animate(withDuration: time) {
                self.tableView.contentOffset..{
                    self.tableView.setContentOffset(.init(x: 0, y: min($0.y - delta, self.tableView.contentSize.height)), animated: false)
                }
                self.view.layoutIfNeeded()
            }
        }
        self.navigationItem.titleView = nil
    }
    
    func adjustTextView() {
        if scene == .floors {
            if textView.text.count > 0 {
                let height = max(min(textView.contentSize.height, 100), 36)
                textViewHeight.constant = height
                bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 16
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            updateCountingLabel(label: replyCountLabel, text: textView.text, lineLimit: 20, charLimit: 817)
        }
    }
    
    @objc func keyboardDidHide(_ sender: Notification) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextView()
    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        adjustTextView()
//    }
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        adjustTextView()
//    }
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        adjustTextView()
//    }
    
    @objc func viewTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
}
