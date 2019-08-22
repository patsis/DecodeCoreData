//
//  ViewController.swift
//  DecodeCoreData
//
//  Created by Harry Patsis on 16/8/19.
//  Copyright © 2019 Harry Patsis. All rights reserved.
//

import UIKit
import CoreData

class CommentCell: UITableViewCell {
  static let reuseIdentifier = "IDCommentCell"
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var email: UILabel!
}


class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  private let persistentContainer = NSPersistentContainer(name: "Comments")
  
  fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Comment> = {
    // Create Fetch Request
    let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
    //let fetchRequest: NSFetchRequest<Comment> = Comment.fetchRequest()
    
    // Configure Fetch Request
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
    
    // Create Fetched Results Controller
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    
    // Configure Fetched Results Controller
    fetchedResultsController.delegate = self
    
    return fetchedResultsController
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
      self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      if let error = error {
        print("Unable to Load Persistent Store")
        print("\(error), \(error.localizedDescription)")
      }
    }
    load()
  }

  func updateView() {
    var hasComments = false
    if let comments = fetchedResultsController.fetchedObjects {
      hasComments = comments.count > 0
    }
    
    tableView.isHidden = !hasComments
    tableView.reloadData()
  }

  
  func clearEntity() {
     // Create Fetch Request
    let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
     
     // Create Batch Delete Request
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
     let managedObjectContext = self.persistentContainer.viewContext
     do {
      try managedObjectContext.execute(batchDeleteRequest)
       
     } catch {
       print("Error clearEntity") // Error Handling
     }
   }
  
  func load() {
    clearEntity()
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments/") else {
      return
    }
    URLSession.shared.dataTask(with: url) {(data, response, error) in
      guard let data = data else {
        return
      }
      
      DispatchQueue.main.async {
        self.parseResponse(forData: data)
      }
    }.resume()
  }
  
  func parseResponse(forData data: Data) {
    do {
      guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
        fatalError("Failed to retrieve managed object context")
      }
      let managedObjectContext = self.persistentContainer.viewContext
      let decoder = JSONDecoder()
      decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
      let _ = try decoder.decode([Comment].self, from: data)
      saveContext()
      try fetchedResultsController.performFetch()
      updateView()
    } catch let error {
      print("Error ->\(error.localizedDescription)")
    }
  }
  
  func saveContext() {
    if persistentContainer.viewContext.hasChanges {
      do {
        try persistentContainer.viewContext.save()
      } catch {
        print("An error occurred while saving: \(error)")
      }
    }
  }
  
} //end of ViewController


//MARK: NSFetchResoultsController
extension ViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
    updateView()
  }
  
}

//MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let comments = fetchedResultsController.fetchedObjects else {
      return 0
    }
    return comments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as? CommentCell else {
      fatalError("Unexpected Index Path")
    }
    
    // Fetch Quote
    let comment = fetchedResultsController.object(at: indexPath)
    
    // Configure Cell
    cell.name.text = comment.name
    cell.email.text = comment.email
    return cell
  }
  
}


