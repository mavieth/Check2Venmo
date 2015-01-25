//
//  ViewController.swift
//  Check2Venmo
//
//  Created by Joseph Lin on 11/26/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TesseractDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tesseract:Tesseract = Tesseract();
        tesseract.language = "eng";
        tesseract.delegate = self;
//        tesseract.setVariableValue("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", forKey: "tessedit_char_whitelist");
        tesseract.image = UIImage(named: "IMG_5684")?.blackAndWhite();
        self.imageView.image = UIImage(named: "IMG_5684")?.blackAndWhite();
        tesseract.recognize();
        
        NSLog("%@", tesseract.recognizedText);
        NSLog("%@", tesseract.getConfidenceByTextline);
        let nsstring = NSString(string: tesseract.recognizedText);
        
        var error: NSError?
        let regex = NSRegularExpression(pattern: "[0-9]+[.][0-9]{2}", options: nil, error: &error);
        regex?.enumerateMatchesInString(tesseract.recognizedText, options: nil, range: NSMakeRange(0, countElements(tesseract.recognizedText)), usingBlock: { (match, flags, stop) -> Void in
            let string = nsstring.substringWithRange(match.range);
            NSLog("%@", string);
        })

        
//        var array = string.componentsSeparatedByString("\n");
//        for line in array {
//            NSLog("%@", (line as NSString).doubleValue);
//        }
        self.textView.text = tesseract.recognizedText;
    }
    
    func progressImageRecognitionForTesseract(tesseract: Tesseract!) {
        self.textView.text = String(tesseract.progress);
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
        return false; // return true, if you need to interrupt tesseract before it finishes
    }

}

