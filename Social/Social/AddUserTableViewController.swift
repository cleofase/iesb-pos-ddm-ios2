//
//  AddUserTableViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 01/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class AddUserTableViewController: UITableViewController {
    var container: NSPersistentContainer? = AppDelegate.persistentContainer

    @IBAction func cancelAddUserButton(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func confirmAddUserButton(_ sender: UIBarButtonItem) {
        if formAddUserIsValid() {
            addUserInDatabase(with: createJPHUserFromForm())
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    @IBOutlet weak var loginUserTextField: UITextField!
    @IBOutlet weak var nameUserTextField: UITextField!
    @IBOutlet weak var emailUserTextField: UITextField!
    @IBOutlet weak var phoneUserTextField: UITextField!
    @IBOutlet weak var websiteUserTextField: UITextField!
    @IBOutlet weak var streetAddressUserTextField: UITextField!
    @IBOutlet weak var suiteAddressUserTextField: UITextField!
    @IBOutlet weak var cityAddressUserTextField: UITextField!
    @IBOutlet weak var zipcodeAddressUserTextField: UITextField!
    @IBOutlet weak var nameCompanyUserTextField: UITextField!
    @IBOutlet weak var catchPraseCompanyUserTextField: UITextField!
    @IBOutlet weak var bsCompanyUserTextField: UITextField!
    
    
    private func formAddUserIsValid() -> Bool {
        if let loginUser = loginUserTextField.text, !loginUser.isEmpty {
        }
        return true
    }
    
    private func createJPHUserFromForm() -> JPHUser {
        let company = JPHCompany(name: nameCompanyUserTextField.text ?? "", catchPhrase: catchPraseCompanyUserTextField.text ?? "", bs: bsCompanyUserTextField.text ?? "")
        let geo = JPHGeo(lat: "-15.841853", lng: "-48.030709")
        let address = JPHAddress(street: streetAddressUserTextField.text ?? "", suite: suiteAddressUserTextField.text ?? "", city: cityAddressUserTextField.text ?? "", zipcode: zipcodeAddressUserTextField.text ?? "", geo: geo)
        let user = JPHUser(id: 0, name: nameUserTextField.text ?? "", username: loginUserTextField.text ?? "", email: emailUserTextField.text ?? "", address: address, phone: phoneUserTextField.text ?? "", website: websiteUserTextField.text ?? "", company: company)
        return user
    }
    
    private func addUserInDatabase(with user: JPHUser) {
        container?.performBackgroundTask { context in
            do {
                _ = try User.findOrCreate(matching: user, in: context)
                try context.save()
            } catch {
                debugPrint(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
