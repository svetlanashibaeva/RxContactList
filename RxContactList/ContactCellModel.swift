//
//  ContactCellModel.swift
//  RxContactList
//
//  Created by Света Шибаева on 30.01.2023.
//

import UIKit

struct ContactCellModel: BaseCellModelProtocol {
    
    let reuseId = "Cell"
    
    let contact: Contact
 
    func configureCell(_ cell: UITableViewCell) {
        guard let contactCell = cell as? TableViewCell else { return }
        
        contactCell.firstName.text = contact.firstName
        contactCell.secondName.text = contact.secondName
        contactCell.phoneNumber.text = contact.phoneNumber
    }
}
