//
//  ViewController.swift
//  Week3TestWork
//
//  Copyright © 2018 E-legion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var bruteForcedTimeLabel: UILabel!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var generatePasswordButton: UIButton!
    
    private let passwordGenerate = PasswordGenerator()
    private let characterArray = Consts.characterArray
    private let maxTextLength = Consts.maxTextFieldTextLength
    private var password = ""
    
    let queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        disableStartButton()
        
        //Hide keyboard on screen tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tap)
        inputTextField.delegate = self
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func generatePasswordButtonPressed(_ sender: UIButton) {
        clearText()
        inputTextField.text = passwordGenerate.randomString(length: 4)
        enableStartButton()
    }
    
    @IBAction func startBruteFoceButtonPressed(_ sender: Any) {
        guard let text = inputTextField.text else {
            return
        }
        password = text
        clearText()
        disableStartButton()
        statusLabel.text = "Status: in process"
        indicator.isHidden = false
        indicator.startAnimating()
        generatePasswordButton.isEnabled = false
        generatePasswordButton.alpha = 0.5
        start()
    }
    
    private func start() {
        let startTime = Date()

        //Создал три операции и передал им разные дипазоны значений для подбора пароля
        //Как только одна из операций заканчивает работу, то у всех выставляется isCanceled = true, данное св-во проверяется в цикле каждой операции: if isCanceled == false - продолжить цикл
        let operationFirst = BruteForceOperation(password: password, startString: "0000", endString: "ZZZZ")
        let operationSecond = BruteForceOperation(password: password, startString: "0000", endString: "zzzz")
        let operationThird = BruteForceOperation(password: password, startString: "aaaa", endString: "ZZZZ")
        
        operationFirst.completionBlock = {
            self.completionBlock(startTime: startTime, operation: operationFirst)
        }
        
        operationSecond.completionBlock = {
            self.completionBlock(startTime: startTime, operation: operationSecond)
        }
        
        operationThird.completionBlock = {
            self.completionBlock(startTime: startTime, operation: operationThird)
        }
        
        self.queue.addOperation(operationFirst)
        self.queue.addOperation(operationSecond)
        self.queue.addOperation(operationThird)
    }
    
    ///Функция для вызова в completionBlock операции
    ///Если операция вернёт результат != "Error", то в очереди queue все будут отменены, если нет, то будет проверено сколько операций в очереди: если осталась одна операция (текущая), то вызываем stop
    private func completionBlock(startTime: Date, operation: BruteForceOperation) {
        var result: String = "Error"
        
        result = operation.result
        
        if result != "Error" {
            self.queue.cancelAllOperations()
            DispatchQueue.main.async {
                self.stop(password: result, startTime: startTime)
            }
        } else if queue.operationCount == 1 {
            DispatchQueue.main.async {
                self.stop(password: result, startTime: startTime)
            }
        }
    }
    
    //Обновляем UI
    private func stop(password: String, startTime: Date) {
        
        indicator.stopAnimating()
        indicator.isHidden = true
        enableStartButton()
        generatePasswordButton.isEnabled = true
        generatePasswordButton.alpha = 1
        passwordLabel.text = "Password is: \(password)"
        statusLabel.text = "Status: Complete"
        bruteForcedTimeLabel.text = "\(String(format: "Time: %.2f", Date().timeIntervalSince(startTime))) seconds"
        
    }
    
    ///отчистит значения у указанных лейблов
    private func clearText() {
        statusLabel.text = "Status:"
        bruteForcedTimeLabel.text = "Time:"
        passwordLabel.text = "Password is:"
    }
    
    private func disableStartButton() {
        startButton.isEnabled = false
        startButton.alpha = 0.5
    }
    
    private func enableStartButton() {
        startButton.isEnabled = true
        startButton.alpha = 1
    }
}

// Добавляем делегат для управления вводом текста в UITextField
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let charCount = inputTextField.text?.count else {
            return
        }
        if charCount != maxTextLength {
            Alert.showBasic(title: "Incorrect password", message: "Password must be 4 characters long", vc: self)
        }
        if charCount > 3 {
            enableStartButton()
        } else {
            disableStartButton()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearText()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let acceptableCharacters = Consts.joinedString
        let characterSet = CharacterSet(charactersIn: acceptableCharacters).inverted
        let newString = NSString(string: text).replacingCharacters(in: range, with: string)
        let filtered = newString.rangeOfCharacter(from: characterSet) == nil
        return newString.count <= maxTextLength && filtered
    }
    
}
