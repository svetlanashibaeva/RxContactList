//
//  NewContactViewController.swift
//  RxContactList
//
//  Created by Света Шибаева on 26.01.2023.
//

import UIKit
import RxSwift
import RxCocoa

class NewContactViewController: UIViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let newContactRelay = PublishRelay<Contact>()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRx()
    }
}

private extension NewContactViewController {
    
    func configureRx() {
        Observable.merge(
            cancelButton.rx.tap.asObservable(),
            addButton.rx.tap.asObservable()
        )
        .bind(with: self) { base, _ in
            base.dismiss(animated: true)
        }
        .disposed(by: bag)
        
        Observable.combineLatest(
            firstNameTextField.rx.text,
            phoneTextField.rx.text
        )
        .map { $0.0 != "" && $0.1 != "" }
        .distinctUntilChanged()
        .bind(to: addButton.rx.isEnabled)
        .disposed(by: bag)
        
        addButton.rx.tap
            .withLatestFrom(
                Observable.combineLatest(
                    firstNameTextField.rx.text.compactMap { $0 },
                    secondNameTextField.rx.text,
                    phoneTextField.rx.text.compactMap { $0 }
                )
            )
            .map { firstName, secondName, phone in
                Contact(firstName: firstName, secondName: secondName, phoneNumber: phone)
            }
            .bind(to: newContactRelay)
            .disposed(by: bag)
    }
}
