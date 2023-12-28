//
//  CreateSubjectViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/16/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class CreateSubjectViewController: UIViewController {

    @IBOutlet weak var SubjectName: UITextField!
    @IBOutlet weak var SubjectTopic: UITextField!
    @IBOutlet weak var DateAndTime: UIDatePicker!
    @IBOutlet weak var CreateSubject: UIButton!
    
    let databaseRef = Database.database().reference().child("subjects")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func CreateSubjectClicked(_ sender: Any) {
        guard let subjectName = SubjectName.text, !subjectName.isEmpty else {
            //handle empty name field
            return
        }
        guard let subjectTopic = SubjectTopic.text, !subjectTopic.isEmpty else {
            //handle empty topic field
            return
        }
        let selectedDateAndTime = DateAndTime.date
        let dateString = formatDateToString(selectedDateAndTime)
        let professorEmail = Auth.auth().currentUser?.email ?? "unknown@example.com"
        CreateASubject(name: subjectName, topic: subjectTopic, dateString: dateString, professorEmail: professorEmail) { error in
            if let error = error {
                    // Handle the error
                    print("Error creating subject: \(error.localizedDescription)")
                } else {
                    // Subject created successfully
                    print("Subject created successfully")
                    // Dismiss the current view controller if needed
                    self.dismiss(animated: true, completion: nil)
                }
        }
        
}
    
    func CreateASubject(name: String, topic: String, dateString: String, professorEmail:String, completion: @escaping (Error?) -> Void) {
        let SubjectRef = databaseRef.childByAutoId()
        let subjectId = UUID().uuidString
        let professorEmail = Auth.auth().currentUser?.email ?? "unknown@example.com"  // Get professor's email
        let SubjectData: [String: Any] = [
            "subjectId":subjectId,
            "name": name,
            "topic": topic,
            "DateAndTime": dateString,
            "Professor": professorEmail
        ]
        SubjectRef.setValue(SubjectData) { (error, _) in
            completion(error)
        }
    }
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    
    func formatStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
