//
//  MainVCMenu.swift
//  Forum
//
//  Created by Oscar on 2020/12/6.
//

import UIKit

extension MainVC {
    
    func blockThread(_ msg: String, _ id: String, report: Bool, isViewing: Bool = true) {
        func commit(_ a: UIAlertAction) {
            DispatchQueue.global().async {
                var success = true
                report => success = Network.reportThread(for: id)
                DispatchQueue.main.async {
                    if success {
                        let li = G.blockedList.content
                        !li.contains(id) => G.blockedList.content = li + [id]
                        self.showAlert(msg, style: .success) {
                            if !report {
                                if isViewing {
                                    if let mvc = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as? MainVC, let dd = mvc.d as? Thread.Manager, let idx = dd.filtered.firstIndex(where: {$0.id == id}) {
                                        mvc.tableView.beginUpdates()
                                        dd.filter()
                                        mvc.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
                                        mvc.tableView.endUpdates()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                } else {
                                    self.refresh()
                                }
                            }
                        }
                    } else { self.networkFailure() }
                }
            }
        }
        self << (UIAlertController(
            title: report ? "你确定要举报吗？" : "你确定要屏蔽吗？",
            message: report ? "受到举报较多的帖子会被隐藏，让我们共同维护良好的社区环境" : "您可以在本地选择屏蔽这个帖子",
            preferredStyle: .alert)..{
                $0.addAction(.init(title: "确认", style: .destructive, handler: commit))
                $0.addAction(.init(title: "取消", style: .cancel))
            })
    }
    
    func setTag(_ id: String, manager dd: Floor.Manager) {
        func commit(tag: Tag) {
            DispatchQueue.global().async {
                let success = Network.setTag(for: id, with: tag)
                DispatchQueue.main.async {
                    if success {
                        dd.thread.myTag = tag
                        self.showAlert("设置成功", style: .success)
                    } else {
                        self.networkFailure()
                    }
                }
            }
        }
        self << (UIAlertController(title: "建议标签", message: "在被多人设置后，帖子将会被打上该种标签，以便不同用户过滤阅读" + (dd.thread.myTag == nil ? "" : "\n\n您已经将其建议为\"\(dd.thread.myTag!.rawValue)\""), preferredStyle: .alert)..{ tagSelect in
            for cs in Tag.allCases {
                tagSelect.addAction(.init(title: cs.rawValue, style: .default, handler: { _ in
                    commit(tag: cs)
                }))
            }
            tagSelect.addAction(.init(title: "取消", style: .cancel, handler: nil))
        })
    }
    
    @objc func firstBtnClicked(_ sender: Any) {
        if scene == .floors, let dd = d as? Floor.Manager {
            let al = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            al.addAction(.init(title: "建议标签", style: .default, handler: { _ in
                self.setTag(dd.thread.id, manager: dd)
            }))
            al.addAction(.init(title: "屏蔽帖子", style: .default, handler: { _ in
                self.blockThread("屏蔽成功", dd.thread.id, report: false)
            }))
            al.addAction(.init(title: "举报帖子", style: .destructive, handler: { _ in
                self.blockThread("举报成功", dd.thread.id, report: true)
            }))
            al.addAction(.init(title: "取消", style: .cancel, handler: nil))
            if let popoverPresentationController = al.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                let fr = self.navigationController!.navigationBar.frame
                popoverPresentationController.sourceRect = .init(x: fr.maxX - 1.0, y: fr.minY, width: 1.0, height: fr.height)
                popoverPresentationController.permittedArrowDirections = .init(rawValue: 0)
            }
            self << al
        } else {
            self.navigationItem.titleView = search
            search.searchBar.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? MainCell else { return nil }
        if scene == .floors {
            let dd = self.d as! Floor.Manager
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {_ in
                UIMenu(title: "", children: [
                    UIAction(title: cell.liked == .disL ? "取消踩" : "踩", image: UIImage(systemName: "hand.thumbsdown"), identifier: nil, attributes:  cell.liked != .like && !cell.folded ? [] : [.disabled], handler: { _ in
                        cell.like(0)
                    }),
                    indexPath.row != 0 ? nil :
                    UIAction(title: "建议标签", image: UIImage(systemName: "square.and.pencil"), identifier: nil, handler: { _ in
                        self.setTag(dd.thread.id, manager: dd)
                    }),
                    indexPath.row != 0 ? nil :
                    UIAction(title: "屏蔽帖子", image: UIImage(systemName: "eye.slash"), identifier: nil, handler: { _ in
                        self.blockThread("屏蔽成功", cell.thread.id, report: false, isViewing: true)
                    }),
                    UIAction(title: indexPath.row == 0 ? "举报帖子" : "举报楼层", image: UIImage(systemName: "exclamationmark.triangle"), identifier: nil, attributes:  !cell.folded ? [.destructive] : [.disabled, .destructive], handler: { _ in
                        if indexPath.row == 0 {
                            self.blockThread("举报成功", cell.thread.id, report: true, isViewing: true)
                        } else {
                            self << (UIAlertController.init(title: "你确定要举报吗？", message: "受到举报较多的楼层会被隐藏，让我们共同维护良好的社区环境", preferredStyle: .alert)..{
                                $0.addAction(.init(title: "确定", style: .destructive, handler: { _ in
                                    
                                    DispatchQueue.global().async {
                                        let success = Network.reportFloor(for: dd.thread.id, floor: cell.floor.id)
                                        DispatchQueue.main.async {
                                            if success {
                                                self.showAlert("举报成功", style: .success)
                                            } else {
                                                self.networkFailure()
                                            }
                                        }
                                    }
                                }))
                                $0.addAction(.init(title: "取消", style: .cancel, handler: nil))
                            })
                        }
                            
                    })
                ].compactMap{$0})
            }
        } else {
            return UIContextMenuConfiguration(identifier: nil) {
                (self.d.didSelectedRow(self, index: indexPath.row, commit: false) as! MainVC)..{
                    $0.inPreview = true
                }
            } actionProvider: {_ in
                UIMenu(title: "", children: [
                    UIAction(title: "屏蔽", image: UIImage(systemName: "eye.slash"), identifier: nil, handler: { (a) in
                        self.blockThread("屏蔽成功", cell.thread.id, report: false, isViewing: false)
                    }),
                    UIAction(title: "举报", image: UIImage(systemName: "exclamationmark.triangle.fill"), identifier: nil, handler: { (a) in
                        self.blockThread("举报成功", cell.thread.id, report: true, isViewing: false)
                    })
                ])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let dest = animator.previewViewController {
            animator.addAnimations {
                self.show(dest, sender: self)
                with ((dest as! MainVC)) {
                    $0.inPreview = false
                    $0.topDist.constant = $0._topDist
                    $0.updateFavour()
                    $0.tableView.refreshControl = $0.refreshControl
                }
            }
        }
    }
    
}
