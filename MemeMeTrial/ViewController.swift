//
//  ViewController.swift
//  MemeMeTrial
//
//  Created by Lanre Akomolafe on 7/22/16.
//  Copyright © 2016 Lanre. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //@IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    //Settings for the text field
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    //MARK: SETUP UI
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        shareButton.enabled = false //until an image is chosen
        
        setupTextFields(topTextField, position: "TOP")
        setupTextFields(bottomTextField, position: "BOTTOM")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setupTextFields(textField: UITextField, position: String) {
        textField.text = position
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }
    
    // MARK: IMAGE PICKER
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        presentPicker(.PhotoLibrary)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        presentPicker(.Camera)
    }
    
    func presentPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = sourceType
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //set the image if the user picked an image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = image
            shareButton.enabled = true
        }
        //dismiss the image picker view controller
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //Dismiss the image picker view controller when user cancels
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: TEXTFIELD DELEGATE FUNCTIONS
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //Clear the default text when the user begins editing
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Resign the textfield and keyboard when the user clicks "enter"
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: KEYBOARD NOTIFICATIONS
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.moveKeyboardUp(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.moveKeyboardDown(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: MOVE KEYBOARD
    
    func moveKeyboardUp(notification: NSNotification) {
        //only move the view up if the bottom textfield is being edited,
        //i.e., is the "firstResponder"
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func moveKeyboardDown(notification: NSNotification) {
        //When the keybpard goes down, return the view's y-coordinate to 0
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //Get height of keuboard from the userInfo dictionary from the NSNotification
        let info = notification.userInfo
        let keyboardSize = info![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //MARK: MEME OBJECT
    
    func save() {
        //Create meme object
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: generateMemedImage())
        print("\(meme.topText)meme was saved")
        
        //Add it to the array of memes in the app delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        print(appDelegate.memes.count)
    }
    
    func generateMemedImage() -> UIImage {
        //Hide toolbar and navbar
        //topToolbar.hidden = true
        bottomToolbar.hidden = true
        
        //Change background to black
        let originalColor: UIColor = self.view.backgroundColor!
        self.view.backgroundColor = UIColor.blackColor()
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        //topToolbar.hidden = false
        bottomToolbar.hidden = false
        
        //Change background back to original
        self.view.backgroundColor = originalColor
        
        return memedImage
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        //create the image
        let memedImage = generateMemedImage()
        
        //set the activity view
        let shareView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //only save if sharing successful
        shareView.completionWithItemsHandler = { activity, success, items, error in
            if (success) {
                self.save()
            }
        }
        //present the view
        self.presentViewController(shareView, animated: true, completion: nil)
    }
    
    //TODO: Might need to get rid of this button
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}