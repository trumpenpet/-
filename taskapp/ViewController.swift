//
//  ViewController.swift
//  taskapp
//
//  Created by 小島大舗 on 2020/07/31.
//  Copyright © 2020 daisuke.kojima. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    /*DB内のタスクが管理されるリスト
    日付の近い順でソート：昇順
 　　以降内容がアップデートするとリスト内も自動で更新*/
    var taskArray = try!Realm().objects(Task.self).sorted(byKeyPath:"date",ascending:true)
    
    //検索結果を入れる配列
    var searchResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
    
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "cellSegue", sender: nil)
        
    }
    
    func tableView(_ tableView:UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle{
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! Realm().write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in for request in requests {
                    print("/--------------")
                    print(request)
                    print("--------------/")
                }
            }
        }
        
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
    
        if segue.identifier == "cellSegue" {
            
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            
        } else {
            
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //検索の流れを実装
        //taskArrayに検索したものを入れる
        //tableViewのリロード
        let predicate = NSPredicate(format: Task.category)
        taskArray = realm.objects(Task.self).filter(predicate)
        tableView.reloadData()
    }
}

