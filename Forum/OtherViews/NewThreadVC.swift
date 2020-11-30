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
    @IBOutlet weak var contentCountLabel: StateLabel!
    @IBOutlet weak var titleCountLabel: StateLabel!
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
    
    lazy var blockDropDown = DropDown()..{
        $0.dataSource = Thread.Category.allCases.dropFirst().map {
            $0.rawValue
        }
        $0.backgroundColor = .systemBackground
        $0.cellHeight = 40
        $0.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
    }
    
    lazy var typeDropDown = DropDown()..{
        $0.dataSource = NameTheme.allCases.map {
            $0.displayText
        }
        $0.backgroundColor = .systemBackground
        $0.cellHeight = 40
        $0.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
    }

    
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
        blockBtn.setTitle("请选择分区", for: .normal)
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
        typeDropDown.selectRow(0)
        
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateCountingLabel(label: titleCountLabel, text: titleTextField.text ?? "", lineLimit: 1, charLimit: 40)
    }
    
    @objc func viewTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    @IBAction func postBtnClicked(_ sender: Any) {
        if let postTitle = titleTextField.text, postTitle != "", let postContent = contentTextField.text, postContent != "" {
            if titleCountLabel.ok && contentCountLabel.ok {
                if let block = Thread.Category(rawValue: blockDropDown.selectedItem ?? "") {
                    (showProgress(), self.typeDropDown.selectedItem!)..{ bar, theme in
                        DispatchQueue.global().async {
                            if Network.newThread(
                                title: postTitle, inBlock: block, content: postContent,
                                anonymousType: NameTheme.allCases.first(where: {$0.displayText == theme})! ,
                                seed: self.checkBtn.checked ? Int.random(in: 1..<1000000) : 0
                            ) {
                                self.setAndHideAlert(bar, "发帖成功", style: .success) {
                                    self.fatherVC.refresh()
                                    self.dismiss(animated: true)
                                }
                            } else { self.setAndHideAlert(bar, "发帖失败", style: .failure) }
                        }
                    }
                } else { showAlert("请选择一个分区", style: .warning) }
            } else { showAlert("请输入合适长度的内容", style: .warning) }
        } else { showAlert("请输入合适长度的内容", style: .warning) }
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
