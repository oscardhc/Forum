//
//  LoginViewController.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var iconImage: UIImageView!
    
    var sentEmail = ""
    var isBase = false
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isBase = presentingViewController == nil
        if traitCollection.userInterfaceStyle == .dark {
            if let filter = CIFilter(name: "CIColorInvert") {
                filter.setValue(CIImage(image: iconImage.image!), forKey: kCIInputImageKey)
                let newImage = UIImage(ciImage: filter.outputImage!)
                iconImage.image = newImage
            }
        }
        isBase => navBar.isHidden = true
    }
    
    @IBAction func sendVerificationCode(_ sender: Any) {
        if let email = emailTextField.text, email.hasSuffix("@sjtu.edu.cn") {
            sentEmail = email
            showProgress()..{ bar in
                DispatchQueue.global().async {
                    Network.requestLogin(with: email)
                        ?> self.setAndHideAlert(bar, "验证码发送成功", style: .success)
                        ?< self.setAndHideAlert(bar, "验证码发送失败", style: .failure)
                }
            }
        } else { showAlert("请填写正确的交大邮箱", style: .warning) }
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        if let code = codeTextField.text, code != "" {
            if sentEmail != "" {
                let bar = showProgress()
                DispatchQueue.global().async {
                    let (success, token) = Network.performLogin(with: self.sentEmail, verificationCode: code)
                    if success {
                        self.setAndHideAlert(bar, "验证成功", style: .success) {
                            G.token.content = token
                            print("Success! token = \(token)")
                            if self.isBase {
                                let vc = *"InitTabVC"
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            } else {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else { self.setAndHideAlert(bar, "验证失败", style: .failure) }
                }
            } else { showAlert("请先发送验证码", style: .warning) }
        } else { showAlert("请填写验证码", style: .warning) }
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
