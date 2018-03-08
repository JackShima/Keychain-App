//
//  RegisterUserViewController.swift
//  EasyKey
//
//  Created by JACK on 07/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailAdressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("Cancel Button Tapped")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        print("SignUp button tapped")
        
        //Validate required fields are not empty
        if
            (firstNameTextField.text?.isEmpty)! ||
                (emailAdressTextField.text?.isEmpty)! ||
                (passwordTextField.text?.isEmpty)!
        {
            //Display alert message and return
            displayMessage(userMessage: "All fields are quired to fill in")
            return
        }
        
        //Validate password
        if
            ((passwordTextField.text?.elementsEqual(repeatPasswordTextField.text!))! != true)
        {
            //Display alert message and return
            displayMessage(userMessage: "Please make sure that passwords match")
            return
        }
        
        //Create Activity Indicator
        let myActivityIndicator =
            UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.gray)
        
        //Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        //If needed, you can prevent Activity Indicator from hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = false
        
        //Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        //send HTTP Request to Register user
        let myURL = URL(string: "https://dev.people.com.ai/mobile/api/v2/register")
        var request = URLRequest(url: myURL!)
        request.httpMethod = "POST" //Compose a query string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["Name": firstNameTextField.text!,
                          "userName": emailAdressTextField.text!,
                          "userPassword": passwordTextField.text!,
                          ] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again")
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error=\(String(describing: error))")
                return
            }
            //Let`s convert response sent from a server side code to a NSDictionary object:
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    
                    let userId = parseJSON["userId"] as? String
                    print("User id: \(String(describing: userId!))")
                    
                    if (userId?.isEmpty)!
                    {
                        //Display an Alert dialog with a friendly error message
                        self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                        return
                    } else {
                        self.displayMessage(userMessage: "Succesfully Registered a New Account. Please proceed to Sign in")
                    }
                } else {
                    //Display an Alert dialog with a friendly error message
                    self.displayMessage(userMessage: "Could not succefully perform this request. Please try again later")
                }
            } catch {
                
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                
                //Display an Alert dialog with a friendly error message
                self.displayMessage(userMessage: "Could not succefully perform this request. Please try again later")
                print(error)
            }
        }
        task.resume()
        
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async
            {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
        }
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default)
                { (action:UIAlertAction!) in
                    //Code in this block will trigger when OK button Tapped.
                    print("OK button tapped")
                    DispatchQueue.main.async
                        {
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
        }
    }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


