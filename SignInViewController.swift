//
//  SignInViewController.swift
//  EasyKey
//
//  Created by JACK on 07/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        print("Sign in button tapped")
        
        //Le os valores
        let userName = userNameTextField.text
        let userPassword = userPasswordTextField.text
        
        //verifica se nao esta vazia
        if (userName?.isEmpty)! || (userPassword?.isEmpty)!
        {
            //Alerta
            print("E-mail \(String(describing: userName)) ou senha \(String(describing: userPassword)) estao vazios")
            displayMessage(userMessage: "Um dos campos esta vazio")
            
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
        let myURL = URL(string: "https://dev.people.com.ai/mobile/api/v2/login")
        var request = URLRequest(url: myURL!)
        
        request.httpMethod = "POST" //Compose a query string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let postString = ["userName": userName!, "userPassword": userPassword!] as [String:String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Algo deu errado")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            self.removeActivityIndicator(myActivityIndicator: myActivityIndicator)
            
            if error != nil
            {
                self.displayMessage(userMessage: "Tivemos um problema com sua tentativa. Tente mais novamente")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    
                    let accessToken = parseJSON["token"] as? String
                    let userId = parseJSON["id"] as? String
                    print("Acess token: \(String(describing: accessToken!))")
                    
                    if (accessToken?.isEmpty)!
                    {
                        self.displayMessage(userMessage: "Algo deu errado. Tente novamente")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        {
                            let homePage =
                                self.storyboard?.instantiateInitialViewController(withIdentifier: "HomeViewController") as! HomePageViewController
                                let appDelegate = UIApplication.shared.delegate
                                appDelegate?.window??.rootViewController = homePage
                        }
                        }
                    }
                    
             else {
                    self.displayMessage(userMessage: "Algo deu errado. Tente novamente")
                }
                
         catch {
                
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                
                self.displayMessage(userMessage: "Algo deu errado")
                print(error)
            }
            } as! (Data?, URLResponse?, Error?) -> Void
    
    
    
        func registerNewAccountButtonTapped(_ sender: Any) {
        print("Register account button tapped")
        
        let registerViewController =
        self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as! RegisterUserViewController
        
        self.present(registerViewController, animated: true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
        }
    }
}
