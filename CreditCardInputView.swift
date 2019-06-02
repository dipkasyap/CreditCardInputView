//
//  CreditCardInputView.swift
//  dpd.ghimire@gmail.com
//  Created by Devi Prasad Ghimire on 31/5/19.
//  Copyright © 2019 Devi Prasad Ghimire. All rights reserved.
//

import UIKit

class CreditCardInputView: UIView {
    
    var viewBorderColorNormal: CGColor = UIColor.lightGray.cgColor
    var viewBorderColorError: CGColor = UIColor.red.cgColor

    enum InputType: Int {
        case cardNumber = 0, cardHolder, expDate, cscNumder
    }
    var didChangeText: (String) -> () = { _ in }
    var didTapNextButton: () -> () = {}
    
    private let textField: UITextField = UITextField()
    
    var text: String {
        set {
            textField.text = newValue
            formatTextField(textField)
        }
        
        get {
            return self.textField.text ?? ""
        }
    }
    
    var type: InputType = .cardHolder {
        didSet {
            switch type {
            case .cardNumber:
                textField.keyboardType = .numberPad
                textField.returnKeyType = .next
            case .cardHolder:
                textField.keyboardType = .default
                textField.autocorrectionType = .no
                textField.returnKeyType = .next
            case .expDate:
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.dataSource = self
                textField.inputView = pickerView
            case .cscNumder:
                textField.keyboardType = .numberPad
                textField.returnKeyType = .done
            }
            let doneToolbar:UIToolbar = UIToolbar()
            doneToolbar.barStyle = .blackTranslucent
            doneToolbar.tintColor = UIColor.white
            
            doneToolbar.items = [
                UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(resignFirstResponder)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
            ]
            
            doneToolbar.sizeToFit()
            textField.inputAccessoryView = doneToolbar
        }
    }
    @IBInspectable var placeHolder: String? {
        set { textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [.foregroundColor : UIColor.lightGray]) }
        get { return textField.placeholder }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initView()
    }
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc func done() {
        endEditing(true)
        didTapNextButton()
    }
}

private extension CreditCardInputView {
    func initView() {
        self.backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2
        self.layer.borderColor = viewBorderColorNormal
        self.layer.borderWidth = 1
        
        do {
            addSubview(textField)
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5).isActive = true
        }
        
        textField.keyboardAppearance = .dark
        textField.textColor = .darkGray
        
        textField.addTarget(self, action: #selector(formatTextField), for: .editingChanged)
        textField.addTarget(self, action: #selector(tapTextFieldReturn), for: .editingDidEndOnExit)
    }
    
    @objc func tapNextButton() {
        didTapNextButton()
    }
    
    @objc func tapTextFieldReturn() {
        textField.resignFirstResponder()
    }
    
    private func validate() {
        
        let text = textField.text!.trimmingCharacters(in: .whitespaces).removeWhitespace()
        
        switch type {
        case .cardNumber:
            self.layer.borderColor =  text.isNumberOnly ? viewBorderColorNormal : viewBorderColorError
        case .cardHolder:
            break
        case .expDate:
            break
        case .cscNumder:
            self.layer.borderColor =  (text.isNumberOnly && text.count <= 4) ? viewBorderColorNormal : viewBorderColorError
        }
    }
    
    @objc func formatTextField(_ sender: UITextField) {
        switch type {
        case .cardNumber:
            let rawText = textField.text?.components(separatedBy: " ").joined() ?? ""
            var newText = String(rawText.prefix(16))
            
            let spaceIndex = [12, 8, 4]
            
            for index in spaceIndex {
                guard newText.count >= index + 1 else { continue }
                newText.insert(" ", at: String.Index(encodedOffset: index))
            }
            
            setText(newText)
            
        case .cardHolder:
            setText(textField.text)
        case .expDate:
            break
        case .cscNumder:
            setText(textField.text)
        }
        
        didChangeText(textField.text ?? "")
        validate()
    }
    
    func setText(_ text: String?) {
        if textField.text != text {
            textField.text = text
        }
        guard let text = text, text.count != 0 else { return
        }
        switch type {
        case .cardNumber:
            if text.count >= 19 {
                endEditing(true)
            }
        case .cardHolder:
            break
        case .expDate:
            break
        case .cscNumder:
//            if text.count >= 4 {
//                endEditing(true)
//            }
            break
        }
    }
}

extension CreditCardInputView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    enum ExpDate: Int, CaseIterable {
        case month
        case year
        var data: [String] {
            switch self {
            case .month:
                return (1...12).map({ String(format: "%02d", arguments: [$0]) })
            case .year:
                let year = Calendar.current.component(.year, from: Date())
                return (year...year + 20).map(String.init)
            }
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return ExpDate.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ExpDate(rawValue: component)?.data.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ExpDate(rawValue: component)?.data[row] ?? ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = ExpDate.month.data[pickerView.selectedRow(inComponent: ExpDate.month.rawValue)]
        let year = ExpDate.year.data[pickerView.selectedRow(inComponent: ExpDate.year.rawValue)]
        setText("\(month)/\(year)")
        didChangeText("\(month)/\(year.suffix(2))")
    }
}
