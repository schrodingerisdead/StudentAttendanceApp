//
//  EnrollSubjectCollectionViewCell.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/18/23.
//
import FirebaseAuth
import FirebaseDatabase
import UIKit

class EnrollSubjectCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var SubjectName: UILabel!
    @IBOutlet weak var SubjectTopic: UILabel!
    @IBOutlet weak var Enroll: UIButton!
    var subjectId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    
    @IBAction func EnrollClicked(_ sender: Any) {
        guard let subjectId = subjectId, let currentUser = Auth.auth().currentUser else {
            print("Error: Subject ID or User ID not available")
            return
        }

        // Reference to the enrolled_subjects node for the current user
        let enrolledSubjectsRef = Database.database().reference().child("enrolled_subjects")

        // Fetch the subject name based on subjectId
        Database.database().reference().child("subjects").child(subjectId).observeSingleEvent(of: .value) { (snapshot) in
            guard let subjectData = snapshot.value as? [String: Any],
                  let subjectName = subjectData["name"] as? String else {
                print("Error: Unable to fetch subject information")
                return
            }

            // Fetch the user's email using currentUser
            let userEmail = currentUser.email ?? ""
            if userEmail.isEmpty {
                print("Error: Unable to fetch user's email")
                return
            }

            // Print or use the fetched information
            print("Enrolling user with email \(userEmail) in subject \(subjectName)")

            // Update the enrolled_subjects node
            enrolledSubjectsRef.child(subjectName).child(userEmail.replacingOccurrences(of: ".", with: "_")).setValue(true) { (error, _) in
                if let error = error {
                    print("Error enrolling subject: \(error.localizedDescription)")
                } else {
                    print("Subject enrolled successfully")
                }
            }
        }
    }
}

