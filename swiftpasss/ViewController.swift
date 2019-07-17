//
//  ViewController.swift
//  swiftpass
//
//  Created by Mael Chemla on 04/07/2019.
//  Copyright © 2019 Mael Chemla. All rights reserved.
//

import CommonCrypto
import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var length: UITextField!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var iterations: UITextField!
    @IBOutlet weak var websiteName: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var characterAZ: UISwitch!
    @IBOutlet weak var character09: UISwitch!
    @IBOutlet weak var characteraz: UISwitch!
    @IBOutlet weak var characterSymbol: UISwitch!
    
    
    var avalaible = [
        "minus" : ["a","b","c","d","f","g","h","i","j","k","l","m","n","p","o","q","r","s","t","u","v","w","x","y","z"],
        "majus" : ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"],
        "symbols" : ["%","&","(","§","è","!","ç","à",")","'","$","^","ù","=","+",":","/",";",".",",","?","-","_","@"],
        "numbers" : ["0","1","2","3","4","5","6","7","8","9"]
    ]
    
    var authorized : [Int : [String]] = [:]
    
    @IBAction func controlLength(_ sender: UITextField) {
        if(length.text == nil || Int(length.text!)! < 8){
            length.text = "8"
        }
        if(Int(length.text!)! > 32){
            length.text = "32"
        }
    }

    
    @IBAction func controlIteration(_ sender: UITextField) {
        if(iterations.text == nil || Int(iterations.text!)! < 1){
            iterations.text = "1"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iterations.text = "1"
        length.text = "32"
        configureTextFields()
    }
    
    private func configureTextFields(){
        loginField.delegate  = self
        passwordField.delegate = self
        websiteName.delegate = self
        iterations.delegate = self
        length.delegate = self
    }
    
    func sha256(string: String) -> Data {
        let messageData = string.data(using:String.Encoding.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {
                messageBytes in CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }
    
    
    @IBAction func generate(_ sender: Any) {
        authorized.removeAll()
        if(characterAZ.isOn){
           authorized.updateValue(avalaible["majus"]!, forKey: authorized.count)
        }
        if(characteraz.isOn){
            authorized.updateValue(avalaible["minus"]!, forKey: authorized.count)
        }
        if(characterSymbol.isOn){
            authorized.updateValue(avalaible["symbols"]!, forKey: authorized.count)
        }
        if(character09.isOn){
            authorized.updateValue(avalaible["numbers"]!, forKey: authorized.count)
        }
        if(authorized.count > 0){
            print("size: \(avalaible.count)")
        
            let login  = loginField.text!
            let password =  passwordField.text!
            let website = websiteName.text!
            var hashString = login +  password  +  website
            for _ in 0..<Int(iterations.text!)!{
                hashString = sha256(string:hashString).map { String(format: "%02hhx", $0) }.joined()
            }
            let passwordGenerated = generateToken(hash: hashString)
            UIPasteboard.general.string = passwordGenerated
            showToast(message: "Password copied", font: UIFont (name: "ArialRoundedMTBold", size: 14)!)
            result.text = passwordGenerated
        }
    }
    
    func generateToken(hash: String) -> String {
        var generatedPassword = ""
        var iterator = 0
        for i in hash.indices{
            let index = iterator % authorized.count
            for scalar in String(hash[i]).unicodeScalars{
                generatedPassword += authorized[index]![Int(scalar.value) % authorized[index]!.count]
            }
            iterator += 1
        }
        print(generatedPassword)
        let desiredLength = generatedPassword.index(generatedPassword.startIndex, offsetBy: Int(length.text!)!)
        return String(generatedPassword[..<desiredLength])
    }
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 8.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
