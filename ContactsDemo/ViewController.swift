//
//  ViewController.swift
//  ContactsDemo
//
//  Created by praveen reddy on 12/31/18.
//  Copyright © 2018 praveen reddy. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

//        fetchContacts()
        
        let picker = CNContactPickerViewController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // use this to pick single contact
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
    }

    // use this to fetch totals contacts data to app to display and customize
    func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let err = error {
                print("failed to access", err)
                return
            }
            if granted {
                print("granted...")
                let keys = [CNContactGivenNameKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print(contact.givenName)
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

