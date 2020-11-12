//
//  LoginViewController.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    var sentEmail = ""
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func sendVerificationCode(_ sender: Any) {
        if let email = emailTextField.text, email.hasSuffix("@sjtu.edu.cn") {
            sentEmail = email
            if !Network.requestLogin(with: email) {
                print("Request Login Failed")
            } else {
                print("Request Success")
            }
        }
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        print(codeTextField.text, sentEmail)
        if let code = codeTextField.text, sentEmail != "" {
            let (success, token) = Network.performLogin(with: sentEmail, verificationCode: code)
            if success {
                G.token = token
                print("Success! token = \(token)")
                dismiss(animated: true, completion: nil)
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
