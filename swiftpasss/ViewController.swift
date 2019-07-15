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
    
    
    @IBOutlet weak var loginField: UITextField!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
    }
    
    private func configureTextFields(){
        loginField.delegate  = self
        passwordField.delegate = self
        websiteName.delegate = self
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
        if(characterAZ.isOn){
           authorized.updateValue(avalaible["majus"]!, forKey: authorized.count)
        }
        if(characteraz.isOn){
            authorized.updateValue(avalaible["minus"]!, forKey: authorized.count)
        }
        if(character09.isOn){
            authorized.updateValue(avalaible["symbols"]!, forKey: authorized.count)
        }
        if(characterSymbol.isOn){
            authorized.updateValue(avalaible["numbers"]!, forKey: authorized.count)
        }
        
        print("size: \(avalaible.count)")
        
        let login  = loginField.text!
        let password =  passwordField.text!
        let website = websiteName.text!
        let testString = login +  password  +  website
        let testHash = sha256(string:testString).map { String(format: "%02hhx", $0) }.joined()
        
        print("testHash: \(testHash)")
        result.text = testHash
    }
    
}
extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
