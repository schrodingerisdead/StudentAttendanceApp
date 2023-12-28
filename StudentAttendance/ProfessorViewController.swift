//
//  ProfessorViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/12/23.
//
import FirebaseAuth
import FirebaseDatabase
import UIKit

class ProfessorViewController: UIViewController {

    @IBOutlet weak var LogOutButton: UIBarButtonItem!
    @IBOutlet weak var ProfessorNameLabel: UILabel!
    @IBOutlet weak var CreateASubject: UIButton!
    @IBOutlet weak var CheckStudentAttendance: UIButton!
    
    
    let databaseRef = Database.database().reference().child("subjects")
    var subjects: [(name: String, topic: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfessorName()
     
    }
    
    func getUserName(forEmail email: String, completion: @escaping (String?) -> Void) {
        let usersRef = Database.database().reference().child("users")

        // Query to find the user with a matching email
        let query = usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email)

        // Observe the matched user(s)
        query.observeSingleEvent(of: .value) { (snapshot) in
            guard let users = snapshot.children.allObjects as? [DataSnapshot] else {
                // Handle the case where the snapshot is not valid
                completion(nil)
                return
            }

            if let user = users.first,
               let userData = user.value as? [String: Any],
               let userName = userData["name"] as? String {
                // User found, return the user's name
                completion(userName)
            } else {
                // User not found or data format is incorrect
                completion(nil)
            }
        }
    }
    
    func loadProfessorName() {
        if let userEmail = Auth.auth().currentUser?.email {
            getUserName(forEmail: userEmail) { [weak self] (userName) in
                DispatchQueue.main.async {
                    if let userName = userName {
                        // Set the student's name to the label
                        self?.ProfessorNameLabel.text = "\(userName)!"
                    } else {
                        // Handle the case where the user's name is not found
                        self?.ProfessorNameLabel.text = "No name found"
                    }
                }
            }
        } else {
            // Handle the case where no user is logged in
            ProfessorNameLabel.text = "Not logged in"
        }
    }
    
    @IBAction func LogOutClicked(_ sender: Any) {
        // Sign out the user
            do {
                try Auth.auth().signOut()
                print("User signed out successfully!")
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }

            // Navigate to the login view controller
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            newViewController.modalPresentationStyle = .fullScreen
            newViewController.modalTransitionStyle = .flipHorizontal
            // Check if the view controller is embedded in a navigation controller
            if let navigationController = self.navigationController {
                // Dismiss the presented view controller (if any)
                if let presentedViewController = self.presentedViewController {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }
                
                // Reset text fields in the login view controller
                if let loginViewController = navigationController.viewControllers.first as? ViewController {
                    loginViewController.Email.text = ""
                    loginViewController.Password.text = ""
                }
                
                // Pop to the root view controller of the original navigation controller
                navigationController.popToRootViewController(animated: true)
            } else {
                // If not embedded in a navigation controller, present the view controller directly
                present(newViewController, animated: true, completion: nil)
            }
    }

}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


