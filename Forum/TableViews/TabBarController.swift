//
//  TabBarController.swift
//  Forum
//
//  Created by Oscar on 2020/11/16.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nav = UINavigationController(rootViewController: MainVC.new(.trends))
        nav.navigationBar.prefersLargeTitles = true
        viewControllers?.insert(nav, at: 1)
        
        tabBar.items?[0].image = UIImage(systemName: "house")
        tabBar.items?[0].selectedImage = UIImage(systemName: "house.fill")
        tabBar.items?[0].title = "首页"
        
        tabBar.items?[1].image = UIImage(systemName: "crown")
        tabBar.items?[1].selectedImage = UIImage(systemName: "crown.fill")
        tabBar.items?[1].title = "趋势"
        
        tabBar.items?[2].image = UIImage(systemName: "person")
        tabBar.items?[2].selectedImage = UIImage(systemName: "person.fill")
        tabBar.items?[2].title = "我"
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if selectedIndex == tabBar.items!.firstIndex(of: item)! {
            let nav = viewControllers?[selectedIndex] as! UINavigationController
            if let vc = nav.viewControllers[0] as? DoubleTapEnabled {
                vc.hasTappedAgain()
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
