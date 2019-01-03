//
//  ViewController.swift
//  ContactsDemo
//
//  Created by praveen reddy on 12/31/18.
//  Copyright © 2018 praveen reddy. All rights reserved.
//http://blogs.innovationm.com/contacts-framework-vs-addressbook-swift-3-0/

import UIKit
import Contacts
import ContactsUI

class ContactAccessError: LocalizedError {
    
    private var desc = ""
    
    init(description: String) {
        desc = description
    }
    
    var errorDescription: String? {
        get {
            return self.desc
        }
    }
}

class ViewController: UIViewController, CNContactPickerDelegate {

    let contactStore = CNContactStore()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let button = UIButton()
        button.frame = CGRect(x: 100, y: 100, width: 180, height: 45)
        button.setTitle("Fetch", for: .normal)
        button.addTarget(self, action: #selector(fetchButtonTapped(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor.black, for: .normal)
        view.addSubview(button)

//        fetchContacts()
        
    }
    
    //Ask permission from user to access contact:-
    public func checkPermissions() throws {
        
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .denied:
            throw ContactAccessError(description: "Access Denied")
        case .notDetermined:
            // In case of not determined request for access
            // If allowed it will return success otherwise return error
            contactStore.requestAccess(for: .contacts, completionHandler:{ success, error in
                if success {
                    print("Access Allowed")
                }
            })
        default:
            break
        }
    }
    
    //alert  to user to allows access contact:-
    func showPermissionAlert() {
        let alert = UIAlertController(title: "", message: "Allow App to access contacts"
            , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            // Open Settings, right to the page with your app’s permissions
            self.openSettings()
        })
        
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        alert.preferredAction = settingAction
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    //    let contactInfo = ContactDetail(firstName: textFieldFirstName.text, lastName: textFieldLastName.text, PhnNo: textFieldPhoneNumber.text, street: textFieldStreet.text, city: textFieldCity.text, state: textFieldState.text, zipCode: textFieldZipCode.text, homeEmail: textFieldHomeEmail.text, workEmail: textFieldWorkEmail.text)
    
    //Save New Contacts:-
    func createContact() {
        let contact = CNMutableContact()
        contact.givenName = "contactInfo.firstName"
        contact.familyName = "contactInfo.lastName"
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: "contactInfo.PhnNo"))]
        
        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = "contactInfo.street"
        homeAddress.city = "contactInfo.city"
        homeAddress.state = "contactInfo.state"
        homeAddress.postalCode = "contactInfo.zipCode"
        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value: homeAddress)]
        
//        let homeEmail = CNLabeledValue(label: CNLabelHome, value: ("contactInfo.homeEmail") as NSString!)
//        let workEmail = CNLabeledValue(label: CNLabelWork, value: ("contactInfo.workEmail") as NSString!)
//        contact.emailAddresses = [homeEmail, workEmail]
        
        // Saving the newly created contact
        saveContact(contact: contact) { [weak self] result in
            if result {
                // show success alert
                let contactDetailVC = CNContactViewController(for: contact)
                contactDetailVC.contactStore = self?.contactStore //CNContactStore()
//                contactDetailVC.title = "Contact Info"
                self?.navigationController?.pushViewController(contactDetailVC, animated: true)
            } else {
                // show something went wrong
            }
        }
    }
    
    func saveContact(contact: CNMutableContact, completion: @escaping (Bool) -> Void) {
        do {
            try checkPermissions()
            
            // Adds the specified contact to the contact store
            let saveRequests = CNSaveRequest()
//            let contactStore = CNContactStore()
            saveRequests.add(contact, toContainerWithIdentifier:nil)
            do {
                
                // Executes a save request and returns success or failure
                try contactStore.execute(saveRequests)
                completion(true)
                
            } catch {
                completion(false)
            }
            
        } catch {
            // in case of access denied this block will execute
            showPermissionAlert()
        }
    }
    
    //Fetch Contacts:-
    func fetchContactsFromPhonebook(searchKey: String) -> [CNContact] {
//        let name = "textFieldName.text"
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPhoneticGivenNameKey] as! [CNKeyDescriptor]//as [Any]
        
        
        return searchContacts(withName: searchKey, keysToFetch: keysToFetch)
    }
    
    func searchContacts(withName: String, keysToFetch: [CNKeyDescriptor]) -> [CNContact] {
        
        var results: [CNContact] = []
        do {
            try checkPermissions()
            
            // Fetch data using some predicate
            let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: withName)
            
            // if you want to fetch only some record of a contact.
            // Then define key to fetch
            let keys = keysToFetch
            
            do {
                // Fetches all unified contacts matching the specified predicate
                let containerResults = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
                results.append(contentsOf: containerResults)
                
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            showPermissionAlert()
        }
        return results
    }
    
    //Delete Contact:-
    let newContact = CNMutableContact()
    
//    let newContact = contactDetail?.mutableCopy() as! CNMutableContact
    
    func deleteContact(contact: CNMutableContact) {
        do {
            try checkPermissions()
//            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            saveRequest.delete(contact)
            do {
                try contactStore.execute(saveRequest)
                
            } catch {
                print(error)
            }
        } catch {
            showPermissionAlert()
        }
    }
    
    
    //Update Contact:-
    func updateContact(contact: CNMutableContact) {
        do {
            try checkPermissions()
//            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            
            saveRequest.update(contact)
            do {
                try contactStore.execute(saveRequest)
                
            } catch {
                print(error)
            }
            
        } catch {
            showPermissionAlert()
        }
    }
    
    @objc func fetchButtonTapped(_ sender: UIButton) {
//        let picker = CNContactPickerViewController()
//        picker.delegate = self
//        present(picker, animated: true, completion: nil)
        
        
        let contacts = fetchContactsFromPhonebook(searchKey: "Focus")
        print(contacts[0])
        
//        fetchContacts()
        createContact()
    }
    
    /*// use this to pick single contact
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print(contact.phoneNumbers.first?.value.stringValue)
    }
    
    // use this to pick multi contacts
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        contacts.forEach { (contact) in
            for data in contact.phoneNumbers {
                let phoneNo = data.value
                print(phoneNo.stringValue)

            }
        }
    }*/

    // use this to fetch totals contacts data to app to display and customize
    func fetchContacts() {
//        let store = CNContactStore()
        contactStore.requestAccess(for: .contacts) { (granted, error) in
            if let err = error {
                print("failed to access", err)
                return
            }
            if granted {
                print("granted...")
                let keys = [CNContactGivenNameKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print(contact.givenName)
                        print(contact.identifier)
                        if contact.givenName == "Focus" {
                            self.deleteContact(contact: contact.mutableCopy() as! CNMutableContact)
                        }
                    })
                } catch let err {
                    print(err)
                }
            } else {
                print("denied...")
            }
        }
    }
}

