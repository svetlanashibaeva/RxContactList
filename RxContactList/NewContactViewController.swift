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
    
    var contact: Contact?
    
    let newContactRelay = PublishRelay<Contact>()
    let deleteContactRelay = PublishRelay<Contact>()
    
    private let bag = DisposeBag()
    
    private let maxNumberCount = 11
    
    private let regex = try? NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.delegate = self
        phoneTextField.keyboardType = .numberPad
        
        configureUI()
        configureRx()
    }
    
    private func format(phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
        guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else { return "" }
        
        let range = NSString(string: phoneNumber).range(of: phoneNumber)
        guard var number = regex?.stringByReplacingMatches(
            in: phoneNumber,
            options: [],
            range: range,
            withTemplate: ""
        ) else { return "" }
        
        if number.first != "7" {
            number = "7" + number
        }
        
        if number.count > maxNumberCount {
            let maxIndex = number.index(number.startIndex, offsetBy: maxNumberCount)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        if shouldRemoveLastDigit {
            let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        let maxIndex = number.index(number.startIndex, offsetBy: number.count)
        let regRange = number.startIndex..<maxIndex
          
        let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})(\\d+)"
        number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-$5", options: .regularExpression, range: regRange)
        
        return "+" + number
    }
}

private extension NewContactViewController {
    
    func configureRx() {
        
        Observable.combineLatest(
            firstNameTextField.rx.text,
            secondNameTextField.rx.text,
            phoneTextField.rx.text
        )
        .map { [contact] firstName, secondName, phone in
            firstName != ""
            && phone != ""
            && (firstName != contact?.firstName
                || secondName != contact?.secondName
                || phone != contact?.phoneNumber)
        }
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
        
        deleteButton.rx.tap
            .compactMap { [contact] _ in
                contact
            }
            .bind(to: deleteContactRelay)
            .disposed(by: bag)
        
        Observable.merge(
            cancelButton.rx.tap.asObservable(),
            addButton.rx.tap.asObservable(),
            deleteButton.rx.tap.asObservable()
        )
        .bind(with: self) { base, _ in
            base.dismiss(animated: true)
        }
        .disposed(by: bag)
    }
    
    func configureUI() {
        guard let contact = contact else { return }
        
        addButton.title = "Save"
        title = "Edit contact"
        deleteButton.isHidden = false
        
        firstNameTextField.text = contact.firstName
        secondNameTextField.text = contact.secondName
        phoneTextField.text = contact.phoneNumber
    }
}

extension NewContactViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullString = (textField.text ?? "") + string
        textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: range.length == 1)
        textField.sendActions(for: .editingChanged)
        return false
    }
}
