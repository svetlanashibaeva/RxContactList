//
//  ViewController.swift
//  RxContactList
//
//  Created by Света Шибаева on 26.01.2023.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewContactButton: UIBarButtonItem!
    
    private let contactsRelay = BehaviorRelay<[Contact]>(value: [Contact(firstName: "Sveta", secondName: "Shibaeva", phoneNumber: "89120381708")])
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRx()
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsRelay.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.configure(person: contactsRelay.value[indexPath.row])
        return cell
    }
}

private extension ViewController {
    
    func configureRx() {
        contactsRelay
            .subscribe(with: self) { base, _ in
                base.tableView.reloadData()
            }
            .disposed(by: bag)
        
        let newContactController = addNewContactButton.rx.tap
            .compactMap { [weak self] _ in
                self?.storyboard?.instantiateViewController(withIdentifier: "NewContact") as? NewContactViewController
            }
            .share()
        
        newContactController
            .flatMap { controller in
                controller.newContactRelay
                    .map { [$0] }
            }
            .withLatestFrom(contactsRelay) { newContact, contacts in
                contacts + newContact
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
