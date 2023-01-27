//
//  TableViewCell.swift
//  RxContactList
//
//  Created by Света Шибаева on 26.01.2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var secondName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    func configure(person: Contact) {
        firstName.text = person.firstName
        secondName.text = person.secondName
        phoneNumber.text = person.phoneNumber
    }
}
