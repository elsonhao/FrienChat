//
//  UserTableViewController.swift
//  FriendChat
//
//  Created by 黃毓皓 on 2017/2/2.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewController: UITableViewController {

    struct userobject {
        var name:String
        var imageUrl:String
        var userID:String
    }
    
    var users = [userobject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
       
    }
    
    func loadData(){
        users = []
        let ref = FIRDatabase.database().reference().child("users")
        ref.observe(.childAdded, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String:String]{
                let user = userobject(name: userDictionary["name"]!, imageUrl: userDictionary["profile_image"]!, userID: snapshot.key)
                
                
                if FIRAuth.auth()?.currentUser?.uid != snapshot.key{
                    self.users.append(user)
                }
                
                self.tableView.reloadData()
            }
            
          
        }, withCancel: nil)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkLogin()
    }

  
    @IBAction func SignOutPressed(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            self.checkLogin()
        } catch  {
            
        }
    }
    
    func checkLogin(){
        if FIRAuth.auth()?.currentUser == nil{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        cell.nameLabel.text = users[indexPath.row].name
        
        let url = URL(string: self.users[indexPath.row].imageUrl)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: url!) { (data, urlresponse, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else{
                cell.profilePicture.image = UIImage(data: data!)
            }
        }
        task.resume()
        return cell
    }
 
    
   

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return users.count
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let index = tableView.indexPathForSelectedRow?.row
        let destination  = segue.destination as! ChatViewController
        destination.toID = users[index!].userID
    }
    

}
