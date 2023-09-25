//
//  MyViewController.swift
//  ImageToText
//
//  Created by MOHAMMED ABDUL BASITHK on 27/02/23.
//

import UIKit

class MyViewController: UIViewController {

    @IBOutlet weak var outPut: UITextView!
    @IBOutlet weak var txtField: UITextField!
    
    var arr : [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func convertClicked(_ sender: Any) {
        arr.removeAll()
        
        var text = txtField.text!
        
        
        let arrCities: [String] = text.components(separatedBy: "Q.")
        
        var str = "INSERT INTO `mds` (`id`, `num`, `question`, `optionA`, `optionB`, `optionC`, `optionD`, `correct`, `note`, `qpNum`) VALUES"
        
        let qpNum = "1"

        var count = 0
        for item in arrCities {
            count = count + 1
            if item == "" {
                continue
            }
            
            let scanner = Scanner(string: item)
            var num: NSString?
            var question: NSString?
            var optionA: NSString?
            var optionB: NSString?
            var optionC: NSString?
            var optionD: NSString?
            
            let numCharSet = NSMutableCharacterSet(charactersIn: "0123456789")
            scanner.scanUpTo(" ", into: &num)
            scanner.scanUpTo("A.", into: &question)
            scanner.scanUpTo("B.", into: &optionA)
            scanner.scanUpTo("C.", into: &optionB)
            scanner.scanUpTo("D.", into: &optionC)
            
            if let que = question as? String {
                question = que.replacingOccurrences(of: "?", with: "", options: .literal, range: nil) as NSString
            }
            
            if let c = optionC{
                optionD = item.components(separatedBy: c as String).last as NSString?
            }
            
            if num != nil && question != nil && optionA != nil && optionB != nil && optionC != nil && optionD != nil {
                var dct : [String : String] = [:]
                dct["num"] = num! as String
                dct["question"] = question! as String
                dct["optionA"] = optionA! as String
                dct["optionB"] = optionB! as String
                dct["optionC"] = optionC! as String
                dct["optionD"] = optionD! as String
                if count == arrCities.count {
                    str.append("(NULL, \"\(num! as String)\", \"\(question! as String)\", \"\(optionA! as String)\", \"\(optionB! as String)\", \"\(optionC! as String)\", \"\(optionD! as String)\", \"\",\"\", \"\(qpNum)\");")
                }else{
                    str.append("(NULL, \"\(num! as String)\", \"\(question! as String)\", \"\(optionA! as String)\", \"\(optionB! as String)\", \"\(optionC! as String)\", \"\(optionD! as String)\", \"\",\"\", \"\(qpNum)\"),")
                }
                
                
                self.arr.append(dct)
            }
            
        }
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: arr, options: [])
        let JsonString = String(data: data!, encoding: String.Encoding.utf8)
        outPut.text = str
        txtField.text = ""
        UIPasteboard.general.string = str
        print(JsonString)
        
    }
    
    @IBAction func copyCLicked(_ sender: Any) {
//        UIPasteboard.general.string = self.outPut.text!
    }

}
