//
//  BlockView.swift
//  Forum
//
//  Created by Oscar on 2020/11/8.
//

import UIKit

extension UIView {
    
    func addBlockBtn() -> [[UIButton]] {
        var btns = [[UIButton]]()
        let r = 4, c = 2
        let w = frame.width / CGFloat(r), h = frame.height / CGFloat(c)
        print("frame", frame)
        for i in 0..<r {
            btns.append([UIButton]())
            for j in 0..<c {
                let btn = UIButton(frame: CGRect(x: frame.minX + w * CGFloat(i), y: frame.minY + h * CGFloat(j), width: w, height: h))
                btn.setTitle("\(i)\(j)", for: .normal)
                if (i + j) % 2 == 0 {
                    btn.backgroundColor = .red
                }
                addSubview(btn)
                btns[i].append(btn)
            }
        }
        return btns
    }
    
}

class BlockView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var btns = [UIButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let r = 4, c = 2
        let w = frame.width / CGFloat(r), h = frame.width / CGFloat(c)
        print("frame", frame)
        for i in 0..<r {
            for j in 0..<c {
                let btn = UIButton(frame: CGRect(x: frame.minX + w * CGFloat(i), y: frame.minY + h * CGFloat(j), width: w, height: h))
                btn.setTitle("\(i)\(j)", for: .normal)
                if (i + j) % 2 == 0 {
                    btn.backgroundColor = .red
                }
                addSubview(btn)
                btns.append(btn)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
