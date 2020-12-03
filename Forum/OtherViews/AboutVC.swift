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
        addKeyCommand(.init(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(esc)))
    }
    
    private var fatherVC: BaseTableVC!
    func withFather(_ vc: BaseTableVC) -> Self {
        fatherVC = vc
        return self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            fatherVC.deselect()
        }
    }
    
    @IBAction func dismissClicked(_ sender: Any) {
//        fatherVC.deselect()
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
