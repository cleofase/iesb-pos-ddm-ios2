//
//  UserDAO.swift
//  Social
//
//  Created by Cleofas Pereira on 27/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
class UserDAO: NSManagedObject {
//    var users: [User]?
//    var dataUsers = Data()
//
//    public func updateUserFromREST() {
//        let getUsersURI = "https://jsonplaceholder.typicode.com/users"
//
//        let urlSessionConfiguration = URLSessionConfiguration.default
//        urlSessionConfiguration.allowsCellularAccess = true
//        urlSessionConfiguration.networkServiceType = .default
//        urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
//        urlSessionConfiguration.isDiscretionary = true
//        urlSessionConfiguration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 4096, diskPath: NSTemporaryDirectory())
//
//        let operationQueue = OperationQueue()
//        operationQueue.qualityOfService = .userInteractive
//        operationQueue.maxConcurrentOperationCount = 5
//        operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//
//        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)
//
//        if let urlGetUsersURI = URL(string: getUsersURI) {
//            var request = URLRequest(url: urlGetUsersURI)
//            request.timeoutInterval = 10
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//            let dataTask = urlSession.dataTask(with: request)
//            dataTask.resume()
//        }
//    }
    
    class func getAll(in context: NSManagedObjectContext) throws -> [UserDAO] {
        let request: NSFetchRequest<UserDAO> = UserDAO.fetchRequest()
        do {
            let usersDAO = try context.fetch(request)
            return usersDAO
        } catch {
            throw error
        }
    }

    class func findOrCreateUser(matching userInfo: User, in context: NSManagedObjectContext) throws -> UserDAO {
        let request: NSFetchRequest<UserDAO> = UserDAO.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", userInfo.name)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Inconsistência no banco de dados! Encontrado mais de um Usuário com o mesmo identificador.")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let userDAO = UserDAO(context: context)
        userDAO.identifier = Int32(userInfo.id)
        userDAO.name = userInfo.name
        userDAO.username = userInfo.username
        return userDAO
    }

}

//extension UserDAO: URLSessionDelegate {
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        dataUsers.append(data)
//    }
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if error == nil {
//            let decoder = JSONDecoder()
//            do {
//                users = try decoder.decode([User].self, from: dataUsers)
////                DispatchQueue.main.async {[unowned self] in
////                    self.tableView.reloadData()
////                }
//            } catch {
//                debugPrint(error)
//            }
//        } else {
//            debugPrint(error!)
//        }
//    }
//}

