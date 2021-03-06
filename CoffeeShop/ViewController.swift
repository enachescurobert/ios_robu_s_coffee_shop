//
//  ViewController.swift
//  Robu's Coffee Shop
//
//  Created by Robert Enachescu on 16/02/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
  
  @IBOutlet weak var simpleCoffeeLbl: UILabel!
  @IBOutlet weak var oreoCoffeeLbl: UILabel!
  @IBOutlet weak var kitKatCoffeeLbl: UILabel!
  @IBOutlet weak var toppingCoffeeLbl: UILabel!
  @IBOutlet weak var billInfo: UILabel!
  @IBOutlet weak var nameLbl: UITextField!
  @IBOutlet weak var phoneTF: UITextField!
  @IBOutlet weak var addressLbl: UITextField!
  @IBOutlet weak var sendOrderBtn: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
  

  let phonePattern = "+## (###) ###-###"
  
  var numberOfSimpleCoffees:Int = 0
  var numberOfOreoCoffees:Int = 0
  var numberOfKitKatCoffees:Int = 0
  var numberOfToppingCoffees:Int = 0
  var ref: DatabaseReference!
  
  // MARK: - Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupHideKeyboardOnTap()
    
    updateUI()
    
    ref = Database.database().reference()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  //  MARK: - IBActions
  @IBAction func incrementTheAmountOfCoffees(_ sender: UIButton) {
    
    switch sender.tag {
    case 1:
      numberOfSimpleCoffees = tryToIncrement(currentNumber: numberOfSimpleCoffees)
      simpleCoffeeLbl.text = String(numberOfSimpleCoffees)
    case 2:
      numberOfOreoCoffees = tryToIncrement(currentNumber: numberOfOreoCoffees)
      oreoCoffeeLbl.text = String(numberOfOreoCoffees)
    case 3:
      numberOfKitKatCoffees = tryToIncrement(currentNumber: numberOfKitKatCoffees)
      kitKatCoffeeLbl.text = String(numberOfKitKatCoffees)
    case 4:
      numberOfToppingCoffees = tryToIncrement(currentNumber: numberOfToppingCoffees)
      toppingCoffeeLbl.text = String(numberOfToppingCoffees)
    default:
      print("No tag was found for existing cases")
    }
    
  }
  
  @IBAction func decrementTheAmountOfCoffees(_ sender: UIButton) {
    
    switch sender.tag {
    case 10:
      numberOfSimpleCoffees = tryToDecrement(currentNumber: numberOfSimpleCoffees)
      simpleCoffeeLbl.text = String(numberOfSimpleCoffees)
    case 20:
      numberOfOreoCoffees = tryToDecrement(currentNumber: numberOfOreoCoffees)
      oreoCoffeeLbl.text = String(numberOfOreoCoffees)
    case 30:
      numberOfKitKatCoffees = tryToDecrement(currentNumber: numberOfKitKatCoffees)
      kitKatCoffeeLbl.text = String(numberOfKitKatCoffees)
    case 40:
      numberOfToppingCoffees = tryToDecrement(currentNumber: numberOfToppingCoffees)
      toppingCoffeeLbl.text = String(numberOfToppingCoffees)
    default:
      print("No tag was found for existing cases")
    }
    
  }
  
  @IBAction func phoneNumberEditingChanged(_ sender: Any) {
    
    guard let text = phoneTF.text else { return }
    phoneTF.text = text.applyPatternOnNumbers(pattern: phonePattern, replacmentCharacter: "#")
  }
  
  @IBAction func makeBill(_ sender: Any) {
    
    if !checkIfFormIsValid() {
      return
    }
    
    sendOrderBtn.isEnabled = true
    
    var totalString = "\(nameLbl.text ?? "")'s Order\n\nCoffees selected:"
    totalString.append(numberOfSimpleCoffees > 0 ? "\n-\(numberOfSimpleCoffees) simple cofees" : "")
    totalString.append(numberOfOreoCoffees > 0 ? "\n-\(numberOfOreoCoffees) oreo cofees" : "")
    totalString.append(numberOfKitKatCoffees > 0 ? "\n-\(numberOfKitKatCoffees) kit kat cofees" : "")
    totalString.append(numberOfToppingCoffees > 0 ? "\n-\(numberOfToppingCoffees) cofees with both toppings" : "")
    totalString.append("\n\nTotal:\n")
    totalString.append("$\(calculateTotal())")
    
    billInfo.lineBreakMode = .byWordWrapping
    billInfo.numberOfLines = 0
    
    viewHeightConstraint.constant = 2200
    
    billInfo.text = totalString
  }
  
  @IBAction func sendOrder(_ sender: Any) {
    
    if !checkIfFormIsValid() {
      sendOrderBtn.isEnabled = false
      return
    }
    
    let alert = UIAlertController(title: "Order request ready to be sent.", message: "Are you sure you finished your order?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
      action in
      let order:Order = Order(name: self.nameLbl.text!, phone: self.phoneTF.text!, address: self.addressLbl.text!, numberOfSimpleCoffees: self.numberOfSimpleCoffees, numberOfOreoCoffees: self.numberOfOreoCoffees, numberOfKitKatCoffees: self.numberOfKitKatCoffees, numberOfToppingCoffees: self.numberOfToppingCoffees)
      
      guard let newRefKey = self.ref.child("orders").childByAutoId().key else { self.showAlert(title: "Request failed!", message: "Please try again later.")
        return }
      self.ref.child("orders").child(newRefKey).setValue(order.getDictionaryForFirebase()) {
        (error:Error?, ref:DatabaseReference) in
        if let error = error {
          print("Data could not be saved: \(error).")
          self.showAlert(title: "Request failed!", message: "Please try again later.")
        } else {
          print("Data saved successfully!")
          self.showAlert(title: "Request sent!", message: "We'll deliver your order as fast as you can blink. Thank you for choosing our app.")
        }
      }
      
      
    }))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    
    self.present(alert, animated: true)
  }
  
  //  MARK: - Utility Methods
  fileprivate func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
      NSLog("The \"OK\" alert occured.")
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func checkIfFormIsValid() -> Bool {
    var isValid = true
    if simpleCoffeeLbl.text == "0" &&
      oreoCoffeeLbl.text == "0" &&
      kitKatCoffeeLbl.text == "0" &&
      toppingCoffeeLbl.text == "0" {
      showAlert(title: "Warning.", message: "You must take at least one coffee.")
      isValid = false
    } else if nameLbl.text == "" {
      showAlert(title: "Warning", message: "You must tell us your name")
      isValid = false
    } else if phoneTF.text == "" {
      showAlert(title: "Warning", message: "You must give us your phone number")
      isValid = false
    } else if let phoneDigits = phoneTF.text?.count {
      if phoneDigits < phonePattern.count {
          showAlert(title: "Warning", message: "You must enter a valid phone number")
          isValid = false
        }
    } else if addressLbl.text == "" {
      showAlert(title: "Warning", message: "You must tell us where to deliver your order")
      isValid = false
    }
    return isValid
  }
  
  @objc func keyboardWillShow(notification:NSNotification) {
    
    let userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    
    var contentInset:UIEdgeInsets = self.scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height
    self.scrollView.contentInset = contentInset
  }
  
  @objc func keyboardWillHide(notification:NSNotification){
    
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    self.scrollView.contentInset = contentInset
  }
  
  func calculateTotal() -> Int {
    return numberOfSimpleCoffees * 3 + numberOfOreoCoffees * 4 + numberOfKitKatCoffees * 4 + numberOfToppingCoffees * 5
  }
  
  func tryToIncrement(currentNumber: Int) -> Int {
    if currentNumber == 15 {
      showAlert(title: "Warning!", message: "You can't have more than 15 coffees of one type.")
      return currentNumber
    }
    return currentNumber + 1
  }
  
  func tryToDecrement(currentNumber: Int) -> Int {
    return currentNumber > 0 ? currentNumber - 1 : currentNumber
  }
  
  func updateUI() {
    addBorderColorTo(textFields:
      [
        self.nameLbl,
        self.addressLbl,
        self.phoneTF
    ])
  }
  
  func addBorderColorTo(textFields: [UITextField]){
    for textField in textFields {
      textField.layer.borderColor = UIColor.lightGray.cgColor
      textField.layer.borderWidth = 0.5
    }
  }
  
}

// MARK: - Extensions
extension UIViewController {
  /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
  func setupHideKeyboardOnTap() {
    self.view.addGestureRecognizer(self.endEditingRecognizer())
    self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
  }
  
  /// Dismisses the keyboard from self.view
  private func endEditingRecognizer() -> UIGestureRecognizer {
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
    tap.cancelsTouchesInView = false
    return tap
  }
}

extension String {
  
  func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
    var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
    for index in 0 ..< pattern.count {
      guard index < pureNumber.count else { return pureNumber }
      let stringIndex = String.Index(utf16Offset: index, in: self)
      if pureNumber.count > pattern.count {
        return String(pureNumber.prefix(pattern.count))
      }
      let patternCharacter = pattern[stringIndex]
      guard patternCharacter != replacmentCharacter else { continue }
      pureNumber.insert(patternCharacter, at: stringIndex)
    }
    return pureNumber
  }
}

