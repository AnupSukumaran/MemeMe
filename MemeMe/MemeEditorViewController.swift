//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Sukumar Anup Sukumaran on 26/07/18.
//  Copyright © 2018 TechTonic. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var toolBar: UIToolbar!
    var memedImage: UIImage?
    
    let memeTextAttributes: [String: Any] = [
        
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -8.0
     
    ]
    
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTextFieldDelegates()
        textFieldAttributesAndTexts()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        ShareButtonStatusCheck()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
        unsubscribeFromKeyBoardNotifications()
    }
    
    
    
    
    func settingTextFieldDelegates() {
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
    }
    
    func textFieldAttributesAndTexts() {
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.text = "TOP"
        topTextField.textAlignment = .center
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = .center
        
    }
    
    func ShareButtonStatusCheck() {
        
        if imagePickerView?.image == nil {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
        
    }
    
    //MARK: Fuctions For Keyboards
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
   
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        
    }
    
    func unsubscribeFromKeyBoardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage!)
        
        print("memeModel = \(meme!)")
    }
    
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.isStatusBarHidden = true
        self.toolBar.isHidden = true
        
        
        UIGraphicsBeginImageContext( self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.isStatusBarHidden = false
        self.toolBar.isHidden = false
        
        return memedImage
        
    }
    
    //MARK: Actions Methods

    @IBAction func pickingImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func camerImagePicker(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        print("Shared")
        
        memedImage = generateMemedImage()
        let message = "Meme from NewMan"
        
        let objects = [message, memedImage!] as [AnyObject]
        
        let actingVC = UIActivityViewController(activityItems: objects , applicationActivities: nil)
        
        actingVC.completionWithItemsHandler = {
            activity, success, items, error in
            
            let alert = UIAlertController(title: "Save The Meme", message: "Do you like to save this meme?", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                
                self.memedImage = self.generateMemedImage()
                self.save()
                
                
            })
            
            let action2 = UIAlertAction(title: "No", style: .destructive, handler: nil)
            
            alert.addAction(action1)
            alert.addAction(action2)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        self.present(actingVC, animated: true, completion: nil)
    }
    
  
}

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.clipsToBounds = true
            
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      dismiss(animated: true, completion: nil)
    }
    
}

extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == topTextField {
            if !textField.hasText {
                textField.text = "TOP"
            }
        }
        
        if textField == bottomTextField {
            if !textField.hasText {
                textField.text = "BOTTOM"
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
}
