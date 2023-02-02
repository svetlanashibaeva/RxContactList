//
//  ContactListViewController.swift
//  RxContactList
//
//  Created by Света Шибаева on 26.01.2023.
//

import UIKit
import RxSwift
import RxCocoa
import Differentiator

class ContactListViewController: UIViewController, RxDataSourcesProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewContactButton: UIBarButtonItem!
    
    private let contactsRelay = BehaviorRelay<[Contact]>(value: [Contact(firstName: "Sveta", secondName: "Shibaeva", phoneNumber: "+7 (912) 038-17-08")])
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRx()
    }
}

private extension ContactListViewController {
    
    func configureRx() {
        contactsRelay
            .map { contacts -> [Section] in
                let cellModels = contacts.map { contact in
                    ContactCellModel(contact: contact)
                }
                return [Section(model: "Contacts", items: cellModels)]
            }
            .bind(to: tableView.rx.items(dataSource: reloadDataSource()))
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .bind(with: tableView) { tableView, indexPath in
                tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: bag)
        
        let selectedContact = tableView.rx.modelSelected(BaseCellModelProtocol.self)
            .map { ($0 as? ContactCellModel)?.contact }
        
        let didTapAdd: Observable<Contact?> = addNewContactButton.rx.tap
            .map { _ in nil }
        
        let newContactController = Observable.merge(selectedContact, didTapAdd)
            .compactMap { [weak self] contact -> NewContactViewController? in
                let controller = self?.storyboard?.instantiateViewController(withIdentifier: "NewContact") as? NewContactViewController
                controller?.contact = contact
                return controller
            }
            .share()
        
        newContactController
            .flatMap { controller in
                controller.newContactRelay
                    .map { [weak controller] newContact in
                        (new: newContact, old: controller?.contact)
                    }
            }
            .withLatestFrom(contactsRelay) { changedContact, contacts in
                if let old = changedContact.old {
                    guard let index = contacts.firstIndex(where: { $0 == old }) else { return contacts }
                    var updatedContacts = contacts
                    updatedContacts[index] = changedContact.new
                    return updatedContacts
                }
                
                return contacts + [changedContact.new]
            }
            .bind(to: contactsRelay)
            .disposed(by: bag)
        
        newContactController
            .flatMap { controller in
                controller.deleteContactRelay
            }
            .withLatestFrom(contactsRelay) { deleteContact, contacts -> [Contact] in
                guard let index = contacts.firstIndex(where: { $0 == deleteContact }) else { return contacts }
                var updatedContacts = contacts
                updatedContacts.remove(at: index)
                return updatedContacts
            }
            .bind(to: contactsRelay)
            .disposed(by: bag)
        
        newContactController
            .bind(with: self) { base, newContactVC in
                let navigationController = UINavigationController()
                navigationController.setViewControllers([newContactVC], animated: true)
                base.present(navigationController, animated: true)
            }
            .disposed(by: bag)
    }
}
