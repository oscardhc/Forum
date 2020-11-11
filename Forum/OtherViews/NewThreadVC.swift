//
//  NewPostViewController.swift
//  Forum
//
//  Created by Haichen Dong on 2020/10/20.
//

import UIKit

class NewThreadVC: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    var blocks: [[UIButton]]!
    var getResult: (() -> (Int, Int))!
    @IBOutlet weak var blockView: UIView!
    
    private var fatherVC: MainVC!
    func withFather(_ vc: MainVC) -> Self {
        fatherVC = vc
        return self
    }
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gridView = GridBtnView.basedOn(view: blockView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        
    }
    
    @objc func viewTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    var gridView: GridBtnView!
    
    @IBAction func postBtnClicked(_ sender: Any) {
        if let postTitle = titleTextField.text, postTitle != "", let postContent = contentTextField.text, postContent != "" {
            if Network.newThread(title: postTitle, block: "1", content: postContent) {
                print("post thread success!")
                fatherVC.refresh()
                dismiss(animated: true)
            } else {
                print("...new thread post failed")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gridView.setFrame(basedOn: blockView.frame)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
