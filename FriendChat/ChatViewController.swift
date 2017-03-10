//
//  ChatViewController.swift
//  FriendChat
//
//  Created by 黃毓皓 on 2017/2/3.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var messageTextfield: UITextField!
    
    var toID : String?
    let fromID = FIRAuth.auth()?.currentUser?.uid
    
    struct messageObject {
        var from : String
        var to :String
        var message :String
        var timeStamp:String
    }
    
    var messages = [messageObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextfield.delegate = self
        chatTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        
        loadMessageData()
        
        //set table properties
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 200
        chatTableView.separatorStyle = .none
        
//        chatTableView.setNeedsLayout()
//        chatTableView.layoutIfNeeded()
        
        
    }
    
    func loadMessageData() {
        messages = []
        let ref = FIRDatabase.database().reference().child("chats")
        ref.observe(.childAdded, with: { (snapshot) in
            if let messageDictionary = snapshot.value as? [String:String]{
                let msg = messageObject(from: messageDictionary["from"]!, to: messageDictionary["to"]!, message: messageDictionary["message"]!, timeStamp: messageDictionary["timeStamp"]!)
                
                if (msg.from == self.fromID && msg.to == self.toID || (msg.from == self.toID && msg.to == self.fromID)){
                    self.messages.append(msg)
                    
//                    self.chatTableView.reloadData()
                    
                    //insertRow方法跟reloadData 很像,只是insertRow 會有動態的更新動畫,會呼叫numberOfRowsInSection 方法,已更新產生新的一列
                    
                   self.chatTableView.insertRows(at: [IndexPath(row:self.messages.count-1,section : 0)], with: .automatic)
                    print("Message as of now \(self.messages.count)")
                    
                    self.scrollToBottom()
                }
            }
           
        }, withCancel: nil)
        
    }
    
    
    func scrollToBottom(){
        let indexPath : IndexPath = IndexPath(row: messages.count-1, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTitle()
    }
    
    func setupTitle(){
        let ref = FIRDatabase.database().reference().child("users").child(toID!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
           // print(snapshot)
            if let userData = snapshot.value as? [String:String] {
                self.navigationBar.title = userData["name"]
            }
            
        }, withCancel: nil)
  
    }
    
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        uploadChat()
        return true
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        
        uploadChat()
        hideKeyboard()
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
        
    }
    
    func uploadChat(){
        guard messageTextfield.text != "" else{
            print("please provide a message to send to user")
            return
        }
        //upload the chat 
        let ref = FIRDatabase.database().reference()
        let chatRef = ref.child("chats").childByAutoId()
        
        let timeStamp  = "\(Date().timeIntervalSince1970)"
        let messageObject: [String:String]  = ["from":fromID!,"to":toID!,"message":messageTextfield.text!,"timeStamp":timeStamp]
        chatRef.updateChildValues(messageObject) { (error, reference) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                print("upload chat sucessfully")
                self.messageTextfield.text = ""
            }
           
        }
        self.messageTextfield.becomeFirstResponder()
    }
    
    // table view method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.chatTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatTableViewCell

        if FIRAuth.auth()?.currentUser?.uid == messages[indexPath.row].to{
            cell.chat1.text = messages[indexPath.row].message
        }
        else{
            cell.chat2.text = messages[indexPath.row].message
        }
        
        
        
//        let textView = UITextView()
//        textView.text =  messages[indexPath.row].message
//        textView.font = UIFont.systemFont(ofSize: 16)
//        cell.addSubview(textView)
        return cell
    }


}
