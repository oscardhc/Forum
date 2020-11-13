//
//  BlockView.swift
//  Forum
//
//  Created by Oscar on 2020/11/8.
//

import UIKit


class GridBtnView: UIView {
    
    static func basedOn(view: UIView) -> GridBtnView {
        let grid = GridBtnView()
        grid.addBlockBtn()
        view.addSubview(grid)
        return grid
    }
    
    class GridButton: UIButton {
        var location = (x: 0, y: 0)
    }
    
    var btns = [[GridButton]]()
    var chosen = (x: 0, y: 0)
    
    func addBlockBtn() {
        let r = 4, c = 2
        
        for i in 0..<r {
            btns.append([GridButton]())
            for j in 0..<c {
                let btn = GridButton(type: .custom)
                btn.setTitle("N", for: .normal)
                btn.setTitleColor(.systemRed, for: .normal)
                btn.location = (i, j)
                btn.addTarget(self, action: #selector(chosenGrid(_:)), for: .touchUpInside)
                if (i + j) % 2 == 0 {
//                    btn.backgroundColor = .red
                }
                addSubview(btn)
                btns[i].append(btn)
            }
        }
        btns[0][0].setTitle("Y", for: .normal)
    }
    
    func setFrame(basedOn f: CGRect) {
        frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        let r = 4, c = 2
        let w = frame.width / CGFloat(r), h = frame.height / CGFloat(c)
        
        for i in 0..<r {
            for j in 0..<c {
                btns[i][j].frame = CGRect(x: w * CGFloat(i), y: h * CGFloat(j), width: w, height: h)
            }
        }
        
    }
    
    @objc func chosenGrid(_ sender: GridButton) {
        btns[chosen.x][chosen.y].setTitle("N", for: .normal)
        chosen = sender.location
        btns[chosen.x][chosen.y].setTitle("Y", for: .normal)
    }
    
    
}
