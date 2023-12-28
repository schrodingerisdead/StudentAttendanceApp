//
//  SignUpViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/12/23.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var StudentProfessorSwitch: UISwitch!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var ConfirmPassword: UITextField!
    @IBOutlet weak var SignUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignUpClicked(_ sender: Any) {
        guard let email = Email.text, !email.isEmpty,
            let password = Password.text, !password.isEmpty,
            let confirmPassword = ConfirmPassword.text, !confirmPassword.isEmpty,
            let name = Name.text, !name.isEmpty else {
             // Handle invalid input
            
               return
        }
           
           // Check if passwords match
           guard password == confirmPassword else {
               // Handle password mismatch
               return
           }
           
           // Register user based on the selected role (Student or Professor)
           if StudentProfessorSwitch.isOn {
               registerUser(email: email, password: password, name: name, userType: "student")
           } else {
               registerUser(email: email, password: password, name: name, userType: "professor")
           }
       }
       
       func registerUser(email: String, password: String, name: String, userType: String) {
           Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
               if let error = error {
                   print("Registration failed: \(error.localizedDescription)")
                   // Handle registration error (show an alert, update UI, etc.)
                   return
               }
               
               // Registration successful
               print("User registered successfully!")
            

            // Additional: Save user details to your database (Firebase Realtime Database, Firestore, etc.)
               self?.saveUserDetailsToDatabase(name: name,email: email, password: password, userType: userType)
               // Navigate to the appropriate view controller based on user type
               self?.navigateToHomeScreen(userType: userType)
           }
       }
       
    func saveUserDetailsToDatabase(name: String, email: String, password: String, userType: String) {
           // Implement code to save user details to your database (Firebase Realtime Database, Firestore, etc.)
           // For simplicity, this example assumes you have a "users" collection in Firebase Realtime Database.
           // You'll need to adapt this based on your database structure.
           
           let user = [
               "name": name,
               "email": email,
               "password": password,
               "userType": userType
               // Add other user details as needed
           ]
           
           // Replace "users" with your actual database collection name
           let usersRef = Database.database().reference().child("users")
           let newChildRef = usersRef.childByAutoId()
           newChildRef.setValue(user) { (error, _) in
            if let error = error {
                print("Error saving users details: \(error.localizedDescription)")
            } else {
                print("User details saves successfully")
            }
            
        }
           // Save user details to the database
           usersRef.childByAutoId().setValue(user)
       }
       
       func navigateToHomeScreen(userType: String) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
           
           if userType.lowercased() == "student" {
               let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentViewController") as! StudentViewController
               navigationController?.pushViewController(studentVC, animated: true)
           } else if userType.lowercased() == "professor" {
               let professorVC = storyboard.instantiateViewController(withIdentifier: "ProfessorViewController") as! ProfessorViewController
               navigationController?.pushViewController(professorVC, animated: true)
           }
       }

}
