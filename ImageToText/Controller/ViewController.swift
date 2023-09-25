//
//  ViewController.swift
//  ImageToText
//
//  Created by Swamita on 22/09/20.
//

import UIKit
import Vision
import AVFoundation
import CropViewController

class ViewController: UIViewController, UINavigationControllerDelegate, AVSpeechSynthesizerDelegate {
    
    var image  = UIImage(named: "sample")
    var textString = ""

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var speechButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    let synthesizer = AVSpeechSynthesizer()
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.isHidden = true
        self.activity.stopAnimating()
        imagePicker.delegate = self
        synthesizer.delegate = self
        
        
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
//        self.imagePicker.sourceType = .camera
//        self.imagePicker.allowsEditing = false
//        self.present(self.imagePicker, animated: true, completion: nil)
        
//        let alert = UIAlertController(title: "Import Image", message: "From where do you want to import your image?", preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
//        }))
//        alert.addAction(UIAlertAction(title: "Capture from Camera", style: .default, handler: { action in
//            self.imagePicker.sourceType = .camera
//            self.imagePicker.allowsEditing = false
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }))
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//        alert.view.tintColor = UIColor(named: "AlertGolden")
//        self.present(alert, animated: true)
    }
    
    //MARK: - Text to Speech
    
    
    
    @IBAction func voiceTapped(_ sender: Any) {
        
        
         if (synthesizer.isPaused) {
            synthesizer.continueSpeaking();
            speechButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                }
         else if (synthesizer.isSpeaking) {
            synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
            speechButton.setImage(UIImage(systemName: "speaker"), for: .normal)
                 }
        else if (!synthesizer.isSpeaking) {
            speechButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            let utterance = AVSpeechUtterance(string: textView.text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            synthesizer.speak(utterance)
                 }

    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let attrString = NSMutableAttributedString(string: utterance.speechString)
        attrString.addAttribute(.foregroundColor, value: UIColor.blue, range: characterRange)
        textView.attributedText = attrString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        textView.attributedText = NSAttributedString(string: utterance.speechString)
        speechButton.setImage(UIImage(systemName: "speaker"), for: .normal)
    }
     
    
    func setTextFormatted(){
        if self.textString == "" {
            return
        }
        self.textView.text = ""
        self.textView.text = self.textString
        var txtArr : [String] = self.textString.components(separatedBy: "a)")

        var question: String = txtArr[0]
        question.remove(at: question.startIndex)
        question.remove(at: question.startIndex)
        self.textView.text = question
        
        var status = false
        
        if txtArr.count > 1 {
            
            txtArr = txtArr[1].components(separatedBy: "b)")
            if txtArr.count > 1 {
                let a: String = txtArr[0]
                
                self.textView.text =  self.textView.text + "\n A : \(a)"
                
                txtArr = txtArr[1].components(separatedBy: "c)")
                if txtArr.count > 1 {
                    
                    let b: String = txtArr[0]
                    self.textView.text =  self.textView.text + "\n B : \(b)"
                    txtArr = txtArr[1].components(separatedBy: "d)")
                    
                    if txtArr.count > 1 {
                        let c: String = txtArr[0]
                        self.textView.text =  self.textView.text + "\n C : \(c)"
                        let d: String = txtArr[1]
                        self.textView.text =  self.textView.text + "\n D : \(d)"
                        
                        status = true
                        
                        print(a,b,c,d)
                    }
                    
                }
                
            }
        }
        
        
        if !status {
            let alert = UIAlertController(title: "Wrong", message: "Please retry", preferredStyle: .actionSheet)
        }
        
        

    }
     
    
    //MARK: - Extract text using Vision
    
    private func recognizeText(image: UIImage) {
        textString = ""
        request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation]
            else {
                fatalError("Invalid Observation")
            }
            for observation in observations{
                guard let topCandidate = observation.topCandidates(1).first
                else {print("No candidate")
                    continue
                }
                self.textString += " \(topCandidate.string)"
                DispatchQueue.main.async {
                    self.setTextFormatted()
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                }
            }
        })
        request.customWords = ["custom"]
        //request.minimumTextHeight = 0.032
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image.cgImage else {
                fatalError("Cant scan")
            }
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
        }
    }
     
    
    func generateAttributedString(with searchTerm: String, targetString: String) -> NSAttributedString? {

        let attributedString = NSMutableAttributedString(string: targetString)
        do {
            let regex = try NSRegularExpression(pattern: searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .diacriticInsensitive, locale: .current), options: .caseInsensitive)
            let range = NSRange(location: 0, length: targetString.utf16.count)
            for match in regex.matches(in: targetString.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
                //attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular), range: match.range)
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
            }
            return attributedString
        } catch {
            NSLog("Error creating regular expresion: \(error)")
            return nil
        }
    }
}

//MARK: - UI ImagePicker Methods

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("Failed to load image!") }
        let cropController = CropViewController(croppingStyle: .default, image: uiImage)
        cropController.delegate = self
        
        self.image = uiImage
                
        imagePicker.dismiss(animated: true, completion: {
            self.present(cropController, animated: true, completion: nil)
        })
    }
}

extension ViewController: CropViewControllerDelegate {
    

    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.image = image
        imageView.image = image
        activity.isHidden = false
        activity.startAnimating()
        self.textView.text = ""
        cropViewController.dismiss(animated: true)
        recognizeText(image: image)
    }
        
        public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            self.image = image
            imageView.image = image
            activity.isHidden = false
            activity.startAnimating()
            self.textView.text = ""
            cropViewController.dismiss(animated: true)
            recognizeText(image: image)
        }
}
