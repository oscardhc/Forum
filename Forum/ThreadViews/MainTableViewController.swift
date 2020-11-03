//
//  MainTableViewController.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import UIKit
import GTMRefresh

class MainTableViewController: UITableViewController {
    
    enum Scene {
        case main, myThreads
    }
    private var scene = Scene.main
    
    var threads = [Thread]()
    
    func setScene(_ s: Scene) -> Self {
        scene = s
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = scene == .main ? "Threads" : "My Threads"
        
        tableView.register(UINib(nibName: "MainCell", bundle: .main), forCellReuseIdentifier: "MainCell")
        tableView.gtm_addRefreshHeaderView {
            print("Refresh!", self.scene)
            sleep(2)
            self.tableView.endRefreshing()
        }
        tableView.gtm_addLoadMoreFooterView {
            print("Load More!", self.scene)
            self.loadMore()
            self.tableView.endRefreshing()
        }
        tableView.headerIdleImage(UIImage())
        tableView
            .pullUpToRefreshText("")
            .pullDownToRefreshText("")
            .releaseToRefreshText("")
            .releaseLoadMoreText("")
            .refreshSuccessText("")
            .refreshFailureText("")
            .refreshingText("")
        
        threads = Network.getThreads(type: .Default)
        for i in 1...10 {
            threads.append(Thread.samplePost())
        }
    }
    
    func loadMore() {
//        let last = threads
    }
    
    @IBAction func newThread(_ sender: Any) {
        present(*"NewThreadVC", animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0
            ? 1
            : threads.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0
            ?  tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath)
            : (tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell).setAsThread(thread: threads[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0
            ? (scene == .main ? 150 : 0)
            : 200
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        (tableView.cellForRow(at: indexPath) as! ContentTableViewCell).mainView.backgroundColor = .red
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        (tableView.cellForRow(at: indexPath) as! ContentTableViewCell).mainView.backgroundColor = .white
        
        if tableView.cellForRow(at: indexPath) is MainCell {
            
            self.navigationController?.pushViewController(
                (*"DetailTableVC" as! DetailTableViewController)
                    .forThread(threads[indexPath.row]),
                animated: true
            )
            
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
