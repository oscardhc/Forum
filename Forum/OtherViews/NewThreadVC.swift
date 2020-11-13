//
//  NewPostViewController.swift
//  Forum
//
//  Created by Haichen Dong on 2020/10/20.
//

import UIKit
import DropDown

class NewThreadVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var contentCountLabel: UILabel!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var checkBtn: CheckerButton!
    
    var blocks: [[UIButton]]!
    var getResult: (() -> (Int, Int))!
    
    private var fatherVC: MainVC!
    func withFather(_ vc: MainVC) -> Self {
        fatherVC = vc
        return self
    }
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    var blockDropDown: DropDown = ({
        let d = DropDown()
        d.dataSource = Thread.Category.allCases.map {
            $0.rawValue
        }
        d.backgroundColor = .systemBackground
        return d
    })()
    
    var typeDropDown: DropDown = ({
        let d = DropDown()
        d.dataSource = NameGenerator.Theme.allCases.map {
            $0.rawValue
        }
        d.backgroundColor = .systemBackground
        return d
    })()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        
        contentTextField.delegate = self
        contentTextField.placeholder = "请输入内容..."
        contentTextField.text = ""
        textViewDidChange(contentTextField)
        
        titleTextField.delegate = self
        titleTextField.text = ""
        _ = textField(titleTextField, shouldChangeCharactersIn: NSRange(), replacementString: "")
        
        blockBtn.addTarget(self, action: #selector(chooseBlock(_:)), for: .touchUpInside)
        blockBtn.setTitle(blockDropDown.dataSource.first!, for: .normal)
        blockBtn.setDropDownStyle(fontSize: 16)
        
        blockDropDown.anchorView = blockBtn
        blockDropDown.selectionAction = { (index: Int, item: String) in
            self.blockBtn.setTitle(item, for: .normal)
        }
        
        typeBtn.addTarget(self, action: #selector(chooseBlock(_:)), for: .touchUpInside)
        typeBtn.setTitle(typeDropDown.dataSource.first!, for: .normal)
        typeBtn.setDropDownStyle(fontSize: 16)
    
        typeDropDown.anchorView = typeBtn
        typeDropDown.selectionAction = { (index: Int, item: String) in
            self.typeBtn.setTitle(item, for: .normal)
        }
        
        checkBtn.setCheckBoxStyle(fontSize: 14)
        checkBtn.setTitle("人名随机排序", for: .normal)
        
    }
    
    @objc func chooseBlock(_ sender: UIButton) {
        if sender === blockBtn {
            blockDropDown.show()
        } else {
            typeDropDown.show()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCountingLabel(label: contentCountLabel, text: contentTextField.text, lineLimit: 20, charLimit: 817)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        updateCountingLabel(label: titleCountLabel, text: titleTextField.text ?? "", lineLimit: 1, charLimit: 40)
        return true
    }
    
    @objc func viewTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    var gridView: GridBtnView!
    
    @IBAction func postBtnClicked(_ sender: Any) {
        if let postTitle = titleTextField.text, postTitle != "", let postContent = contentTextField.text, postContent != "" {
            if Network.newThread(title: postTitle, inBlock: Thread.Category(rawValue: blockDropDown.selectedItem!)!, content: postContent, anonymousType: NameGenerator.Theme(rawValue: typeDropDown.selectedItem!)!, seed: checkBtn.checked ? Int.random(in: 1..<1000000) : 0) {
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
