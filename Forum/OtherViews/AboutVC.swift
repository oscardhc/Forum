//
//  AboutViewController.swift
//  Forum
//
//  Created by Oscar on 2020/11/9.
//

import UIKit

class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private var fatherVC: MiscVC!
    func withFather(_ vc: MiscVC) -> Self {
        fatherVC = vc
        return self
    }
    
    @IBAction func dismissClicked(_ sender: Any) {
        fatherVC.deselect()
        dismiss(animated: true, completion: nil)
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
