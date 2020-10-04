//
//  AboutViewController.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func accountBtnClicked(_ sender: Any) {
        present(
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "LoginVC"),
            animated: true, completion: nil
        )
//        self.navigationController?.pushViewController(
//            UIStoryboard(name: "Main", bundle: nil)
//                .instantiateViewController(identifier: "LoginVC"),
//            animated: true
//        )
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
