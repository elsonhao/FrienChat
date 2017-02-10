//
//  ViewController.swift
//  FriendChat
//
//  Created by 黃毓皓 on 2017/2/2.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var LoginRegister: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextFiled: UITextField!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var signInbutton: UIButton!
    @IBOutlet weak var signUpbutton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpbutton()
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileimage)))
    }
    
    func selectProfileimage(){
        let imagePickerController  = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            profilePicture.image = editImage
        }else if let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profilePicture.image = originImage
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    

    func setUpbutton(){
        signInbutton.layer.cornerRadius = 5
        signInbutton.clipsToBounds = true
        signUpbutton.layer.cornerRadius = 5
        signUpbutton.clipsToBounds = true
        
    }
    
    @IBAction func LoginRegisterClicked(_ sender: Any) {
        LoginRegister.selectedSegmentIndex == 0 ? enableDisavle(modeLogin: true) : enableDisavle(modeLogin: false)
    }
    
    func enableDisavle(modeLogin:Bool){
    nameTextField.isEnabled = !modeLogin
    signInbutton.isEnabled = modeLogin
    signUpbutton.isEnabled = !modeLogin
    profilePicture.isUserInteractionEnabled = !modeLogin
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkLoginin()
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        
        guard let email = emailTextFiled.text,emailTextFiled.text != "" , let password = passwordTextField.text , passwordTextField.text != "" else {
            print("please provide email,password to login")
            return
        }
        activityIndicator.startAnimating()
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                self.checkLoginin()
            }
        })
        
    }
    
    
    func checkLoginin(){
        if FIRAuth.auth()?.currentUser != nil{
            self.performSegue(withIdentifier: "appSegue", sender: self)
            stopAnimating()
        }
    }
    @IBAction func signUpPressed(_ sender: Any) {
        
        guard  let name  = nameTextField.text, nameTextField.text != "",let password = passwordTextField.text ,passwordTextField.text != "" , let email = emailTextFiled.text , emailTextFiled.text != "" else {
            print("please provide name,emailand password to sin up")
            return
        }
        
        activityIndicator.startAnimating()
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error?.localizedDescription )
                self.stopAnimating()
            }else{
            
                guard let userID = user?.uid else{
                    self.stopAnimating()
                    print("error fetch user ID")
                    return
                }
                
                //store image in File Storage
                
                let imageName:String = userID + "_profile_image.jpg"
                let storageRef  = FIRStorage.storage().reference()
                let profileImagesRef = storageRef.child("profile_images").child(imageName)
                let imageData:Data =  UIImageJPEGRepresentation(self.profilePicture.image!, 0.4)!
                
                profileImagesRef.put(imageData, metadata: nil, completion: { (metaData, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.stopAnimating()
                        return
                    }
                    
                    let imageURL:String = (metaData?.downloadURL()?.absoluteString)!
                    
                    
                    
                    //store User Data in the Data base
                    let ref = FIRDatabase.database().reference()
                    let userRef = ref.child("users").child(userID)
                    let userObject = ["name":name,"email":email,"profile_image":imageURL]
                    userRef.updateChildValues(userObject, withCompletionBlock: { (error, dbreference) in
                        if error != nil{
                            print(error?.localizedDescription)
                            self.stopAnimating()
                        }
                        else{
                            self.stopAnimating()
                            print("All Record Save Sucessfully")
                            self.checkLoginin()
                        }
                    })
                })
                
               
            }
        })
        
    }
    
    func stopAnimating(){
        if activityIndicator.isAnimating{
            activityIndicator.stopAnimating()
        }
    }
    
    


}

