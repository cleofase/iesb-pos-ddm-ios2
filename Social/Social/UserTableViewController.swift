//
//  UserTableViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 24/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class UserTableViewController: UITableViewController {
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    
    private var users: [User]?
    fileprivate var dataUsers = Data()
    private let getUsersURI = "https://jsonplaceholder.typicode.com/users"
    
    @IBAction func updateFromRESTButton(_ sender: UIBarButtonItem) {
        getUsersFromService()
        tableView.reloadData()
    }
    
    @IBAction func updateFromCoreDataButton(_ sender: UIBarButtonItem) {
        getUsersFromDatabase()
        tableView.reloadData()
    }
    
    private func getUsersFromService() {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.allowsCellularAccess = true
        urlSessionConfiguration.networkServiceType = .default
        urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        urlSessionConfiguration.isDiscretionary = true
        urlSessionConfiguration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 4096, diskPath: NSTemporaryDirectory())
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        
        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)
        
        if let urlGetUsersURI = URL(string: getUsersURI) {
            var request = URLRequest(url: urlGetUsersURI)
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = urlSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    private func getUsersFromDatabase() {
        var usersFromDatabase = [User]()
        do {
            if let context = container?.viewContext {
                let usersDAO = try UserDAO.getAll(in: context)
                for userDAOInfo in usersDAO {
                    let user = User(id: Int(userDAOInfo.identifier), name: userDAOInfo.name ?? "", username: userDAOInfo.username ?? "")
                    usersFromDatabase.append(user)
                }
                users = usersFromDatabase
            }
        } catch {
            debugPrint(error)
        }
        
    }
    
    fileprivate func updateDatabase(with users: [User]) {
        container?.performBackgroundTask {context in
            for userInfo in users {
                _ = try? UserDAO.findOrCreateUser(matching: userInfo, in: context)
            }
            try? context.save()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersFromService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseUserCell", for: indexPath)
        cell.textLabel?.text = users?[indexPath.row].name
        cell.detailTextLabel?.text = users?[indexPath.row].username
        return cell
    }

}

extension UserTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        dataUsers.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            let decoder = JSONDecoder()
            do {
                users = try decoder.decode([User].self, from: dataUsers)
                DispatchQueue.main.async {[unowned self] in
                    self.tableView.reloadData()
                }
                updateDatabase(with: users!)
            } catch {
                debugPrint(error)
            }
        } else {
            debugPrint(error!)
        }
        
    }
}
