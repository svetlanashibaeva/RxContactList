//
//  BaseCellModel.swift
//  RxContactList
//
//  Created by Света Шибаева on 30.01.2023.
//

import UIKit

protocol BaseCellModelProtocol {
    var reuseId: String { get }
    func configureCell(_ cell: UITableViewCell)
}
