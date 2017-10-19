//
//  AddUserTableViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 01/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class AddUserTableViewController: UITableViewController {
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    var locationAddressUser: CLLocation?
    
    private let activityIndicator = CustomActivityIndicator()

    @IBAction func cancelAddUserButton(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func confirmAddUserButton(_ sender: UIBarButtonItem) {
        confirmAddUser()
    }
    
    @IBOutlet weak var loginUserTextField: RequiredTextField!
    @IBOutlet weak var nameUserTextField: RequiredTextField!
    @IBOutlet weak var emailUserTextField: EmailTextField!
    @IBOutlet weak var phoneUserTextField: RequiredTextField!
    @IBOutlet weak var websiteUserTextField: URLTextField!
    @IBOutlet weak var streetAddressUserTextField: RequiredTextField!
    @IBOutlet weak var suiteAddressUserTextField: RequiredTextField!
    @IBOutlet weak var cityAddressUserTextField: RequiredTextField!
    @IBOutlet weak var zipcodeAddressUserTextField: RequiredTextField!
    @IBOutlet weak var nameCompanyUserTextField: RequiredTextField!
    @IBOutlet weak var catchPraseCompanyUserTextField: RequiredTextField!
    @IBOutlet weak var bsCompanyUserTextField: RequiredTextField!
   
    fileprivate var textFields = [UITextField]()
    
    fileprivate func confirmAddUser() {
        if performFormValidation() {
            let jphUser = createJPHUserFromForm()
            addUserInDatabase(with: jphUser)
            addUserInService(with: jphUser)
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    private func performFormValidation() -> Bool {
        var isValid: Bool = true

        for textField in textFields {
            textField.resignFirstResponder()
            let validatingTextField = textField as! Validable
            if validatingTextField.isValid() {
                textField.clearMark()
            } else {
                textField.markAsNotValid()
                isValid = false
            }
        }
        
        return isValid
    }
    
    private func createJPHUserFromForm() -> JPHUser {
        let company = JPHCompany(name: nameCompanyUserTextField.text ?? "", catchPhrase: catchPraseCompanyUserTextField.text ?? "", bs: bsCompanyUserTextField.text ?? "")
        let geo = JPHGeo(lat: locationAddressUser?.coordinate.latitude.description ?? "", lng: locationAddressUser?.coordinate.longitude.description ?? "")
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

    private func addUserInService(with user: JPHUser) {
        var jsonDataUser = Data()
        let jsonEncoder = JSONEncoder()
        do {
            jsonDataUser.append(try jsonEncoder.encode(user))
        } catch {
            debugPrint(error)
        }
        
        let userURI = "https://jsonplaceholder.typicode.com/users"
        if let urlUserURI = URL(string: userURI) {
            var request = URLRequest(url: urlUserURI)
            activityIndicator.show(at: self.view)
            request.httpMethod = "POST"
            request.timeoutInterval = 10
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonDataUser
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    // Atualizar id do User no CoreData
                }
                DispatchQueue.main.async {
                    self.activityIndicator.hide()
                    self.navigationController?.dismiss(animated: true)
                }
            }
            dataTask.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Novo Usuário"
        
        loginUserTextField.delegate = self
        textFields.append(loginUserTextField)
        
        nameUserTextField.delegate = self
        textFields.append(nameUserTextField)
        
        emailUserTextField.delegate = self
        textFields.append(emailUserTextField)
        
        phoneUserTextField.delegate = self
        textFields.append(phoneUserTextField)
        
        websiteUserTextField.delegate = self
        textFields.append(websiteUserTextField)
        
        streetAddressUserTextField.delegate = self
        textFields.append(streetAddressUserTextField)
        
        suiteAddressUserTextField.delegate = self
        textFields.append(suiteAddressUserTextField)
        
        cityAddressUserTextField.delegate = self
        textFields.append(cityAddressUserTextField)
        
        zipcodeAddressUserTextField.delegate = self
        textFields.append(zipcodeAddressUserTextField)
        
        nameCompanyUserTextField.delegate = self
        textFields.append(nameCompanyUserTextField)
        
        catchPraseCompanyUserTextField.delegate = self
        textFields.append(catchPraseCompanyUserTextField)
        
        bsCompanyUserTextField.delegate = self
        textFields.append(bsCompanyUserTextField)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddUserTableViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let validableTextField = textField as! Validable
        if validableTextField.isValid() {
            textField.clearMark()
        } else {
            textField.markAsNotValid()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            if let currentIndex = textFields.index(of: textField) {
                let nextTextField = textFields[currentIndex + 1]
                nextTextField.becomeFirstResponder()
            }
        }
        if textField.returnKeyType == .send {
            confirmAddUser()
        }
        resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.placeholder == "Nome Completo" {
            self.navigationItem.title = "\(textField.text ?? "")\(string)"
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressFromMapSegue" {
            if let destination = segue.destination as? AddressFromMapViewController {
                destination.locationAddress = self.locationAddressUser
                destination.delegate = self
            }
        }
    }
    
}

extension AddUserTableViewController: AddressFromMapDelegate {
    func addressFromMap(didUpdateAddressFromMap location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) {[unowned self](placemarks, error) in
            if error == nil {
                self.locationAddressUser = location
                let placemark = placemarks?[0]
                self.streetAddressUserTextField.text = placemark?.thoroughfare
                self.suiteAddressUserTextField.text = placemark?.subThoroughfare
                self.zipcodeAddressUserTextField.text = placemark?.postalCode
                self.cityAddressUserTextField.text = placemark?.locality
            }
        }
    }
}
