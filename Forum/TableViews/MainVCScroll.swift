//
//  MainVCScroll.swift
//  Forum
//
//  Created by Oscar on 2020/11/30.
//

import UIKit

extension MainVC: UIScrollViewDelegate {
    
    func changeBar(hide: Bool) {
        if let bar = self.tabBarController?.tabBar {
            let offset = UIScreen.main.bounds.height - (hide ? 0 : bar.frame.height)
            if offset == bar.frame.origin.y { return }
            UIView.animate(withDuration: 0.3) {
                self.newThreadBtn.frame.origin = CGPoint(x: self.newThreadBtn.frame.minX, y: offset - 80)
                bar.frame.origin.y = offset
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        #if !targetEnvironment(macCatalyst)
        scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
            ?> self.changeBar(hide: true)
            ?< self.changeBar(hide: false)
        #endif
        
        if scene == .floors {
            let ntitle = scrollView.contentOffset.y > 30
                ? "\((d as! Floor.Manager).thread.title)"
                : "#\((d as! Floor.Manager).thread.id)"
            if ntitle != navigationItem.title {
                navigationController?.navigationBar.layer.add(
                    CATransition()..{
                        $0.duration = 0.2
                        $0.type = .fade
                    }, forKey: "fadeText")
                navigationItem.title = ntitle
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.tryDoubleTapping => {
            self.tryDoubleTapping = false
            self.hasTappedAgain()
        }
    }
    
}
