

import UIKit
import RealmSwift   // ←追加
import UserNotifications    // 追加

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
  
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!//【課題】サーチバー
    
    // Realmインスタンスを取得する
    var realm = try! Realm()  // ←追加
    var searchText = ""
    var taskText = ""
    var categoryText = ""
    var hyouji = ""
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    // DB内のタスクが格納されるリスト。
        // 日付の近い順でソート：昇順
        // 以降内容をアップデートするとリスト内は自動的に更新される。
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            tableView.delegate = self
            tableView.dataSource = self
            searchBar.delegate = self
            //何も入力されていなくてもReturnキーを押せるようにする。
            searchBar.enablesReturnKeyAutomatically = false
            searchBar.placeholder = "カテゴリーを入力してください"
            searchBar.showsCancelButton = true
            tableView.reloadData()
            
    }
 
    // データの数（＝セルの数）を返すメソッド
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return taskArray.count
      }
    // 各セルの内容を返すメソッド
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // 再利用可能な cell を得る
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Cellに値を設定する.  --- ここから ---
        
        let task = taskArray[indexPath.row]
        categoryText = task.category
        taskText = task.title
        hyouji = "【" + categoryText + "】" + taskText
        
        cell.textLabel?.text = hyouji
       

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- ここまで追加 ---
        
           return cell
}
//【課題】サーチバーを動かした時
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       searchBar.endEditing(true)
    
      // 検索文字列が空の場合はフィルターをかけない
       if(searchBar.text == "") {
           taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        
      }else{
           searchText = searchBar.text!
           taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).filter("category BEGINSWITH %@", searchText)
    
       }
       tableView.reloadData()
       }
    
     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
      //テーブルを再読み込みする。
     tableView.reloadData()
    }
        
    // 各セルを選択した時に実行されるメソッド
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
        }
    // セルが削除が可能なことを伝えるメソッド
      func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
          return .delete
      }
    // Delete ボタンが押された時に呼ばれるメソッド
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
           if editingStyle == .delete {
               // 削除するタスクを取得する
               let task = self.taskArray[indexPath.row]

               // ローカル通知をキャンセルする
               let center = UNUserNotificationCenter.current()
               center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

               // データベースから削除する
               try! realm.write {
                   self.realm.delete(task)
                   tableView.deleteRows(at: [indexPath], with: .fade)
               }

               // 未通知のローカル通知一覧をログ出力
               center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                   for request in requests {
                       print("/---------------")
                       print(request)
                       print("---------------/")
                   }
               }
           } // --- ここまで変更 ---
       }
    // segue で画面遷移する時に呼ばれる
       override func prepare(for segue: UIStoryboardSegue, sender: Any?){
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
    // 入力画面から戻ってきた時に TableView を更新させる
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          tableView.reloadData()
      }
   }
