//
//  NewPostViewController.swift
//  Forum
//
//  Created by Haichen Dong on 2020/10/20.
//

import UIKit

class NewThreadViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
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
    }
    
    @IBAction func postBtnClicked(_ sender: Any) {
        if let postTitle = titleTextField.text, let postContent = contentTextField.text {
            if Network.newThread(title: postTitle, block: "1", content: postContent) {
                print("post thread success!")
                fatherVC.refresh()
                dismiss(animated: true)
            } else {
                print("...new thread post failed")
            }
        }
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
