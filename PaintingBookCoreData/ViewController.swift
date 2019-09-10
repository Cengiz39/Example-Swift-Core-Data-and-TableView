//
//  ViewController.swift
//  PaintingBookCoreData
//
//  Created by Cengiz Baygın on 9.09.2019.
//  Copyright © 2019 Cengiz Baygın. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDelegate , UITableViewDataSource , UINavigationControllerDelegate{
    var nameArray = [String]()
    var idArray = [UUID]()
    var arraysCounter = Int()
    var chosenArt = String()
    var chosenId = UUID()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.bookmarks, target: self, action: #selector(addButtonClicked))
        tableView.dataSource = self
        tableView.delegate = self
        getData()
        getDatabaseCount()
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name:
            NSNotification.Name.init("newData"), object: nil)
    }
    func getDatabaseCount(){
        if idArray.count == 0 {
            navigationItem.title = "Listelenecek hiçbir eleman yok."
        }else {
            navigationItem.title = "Listelenen Elemanlar: \(idArray.count)"
        }
    }
    @objc func getData() {
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        let coreDelegate = UIApplication.shared.delegate as! AppDelegate
        let coreContext  = coreDelegate.persistentContainer.viewContext
        let corefetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PaintingDB")
        do {// do first
            let fetchResults = try coreContext.fetch(corefetchRequest)
            for resultArray in fetchResults as! [NSManagedObject] {
                if let dataName = resultArray.value(forKey: "name") as? String{
                    self.nameArray.append(dataName)
                    self.tableView.reloadData()
                }
                if let dataId = resultArray.value(forKey: "id") as? UUID {
                    self.idArray.append(dataId)
                    self.tableView.reloadData()
                }
                if idArray.count == 0 {
                    navigationItem.title = "Listelenecek hiçbir eleman yok."
                }else {
                    navigationItem.title = "Listelenen Elemanlar: \(idArray.count)"
                }
            }
            
        } catch  {
            print("Error!")
        } // do last
    }
    @objc func addButtonClicked(){
        chosenArt = ""
        self.performSegue(withIdentifier: "SecondPage", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()
        tableViewCell.textLabel?.text = nameArray[indexPath.row]
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let appContext = appDelegate.persistentContainer.viewContext
            var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PaintingDB")
            var idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate.init(format: "id = %@", idString)
            do {
            let fetchResults = try appContext.fetch(fetchRequest)
                for resultArray in fetchResults as! [NSManagedObject] {
                    if let id = resultArray.value(forKey: "id") as? UUID{
                        appContext.delete(resultArray)
                        idArray.remove(at: indexPath.row)
                        nameArray.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        getDatabaseCount()
                        do {
                            try appContext.save()
                        } catch {
                            print("Error!")
                        }
                        break
                    }
                }
                
            } catch {
               
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenArt = nameArray[indexPath.row]
        chosenId = idArray[indexPath.row]
        self.performSegue(withIdentifier: "SecondPage", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SecondPage" {
            let destinationViewController = segue.destination as! SecondViewController
            destinationViewController.selectedArtBook = chosenArt
            destinationViewController.selectedId = chosenId
        }
    }
}

