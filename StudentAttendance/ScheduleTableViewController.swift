//
//  ScheduleTableViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/20/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ScheduleTableViewController: UITableViewController, ScheduleTableViewCellDelegate{

    struct EnrolledSubject {
        var subjectId: String?
        var name: String
        var topic: String
        var date: String
        var time: String
        // Add other properties as needed
    }

    var enrolledSubjects: [EnrolledSubject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
        fetchAllSubjectsFromFirebase()
    }

    private func fetchAllSubjectsFromFirebase() {
        let subjectsRef = Database.database().reference().child("subjects")

        subjectsRef.observeSingleEvent(of: .value) { snapshot in
            guard let subjectsData = snapshot.value as? [String: [String: Any]] else {
                print("No subjects data found.")
                print("Subjects Snapshot: \(snapshot)")
                return
            }

            // Iterate through all subjects
            for (subjectName, subjectDetails) in subjectsData {
                guard let subjectId = subjectDetails["subjectId"] as? String,
                      let name = subjectDetails["name"] as? String,
                      let topic = subjectDetails["topic"] as? String,
                      let dateTimeString = subjectDetails["DateAndTime"] as? String
                else {
                    print("Error: Unable to extract subject details for \(subjectName)")
                    continue
                }

                // Split date and time from dateTimeString (assuming a specific format)
                let dateTimeComponents = dateTimeString.components(separatedBy: " ")
                let date = dateTimeComponents[0]
                let time = dateTimeComponents[1]

                // Create an EnrolledSubject object and add it to the array
                let enrolledSubject = EnrolledSubject(subjectId: subjectId, name: name, topic: topic, date: date, time: time)
                self.enrolledSubjects.append(enrolledSubject)
            }

            // Reload the table view after fetching all subjects
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrolledSubjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell

        let enrolledSubject = enrolledSubjects[indexPath.row]
        cell.SubjectName.text = enrolledSubject.name
        cell.SubjectDateAndTime.text = "Date: \(enrolledSubject.date) Time: \(enrolledSubject.time)"
        cell.delegate=self
        return cell
    }
    
    
    func didTapAttendButton(in cell: ScheduleTableViewCell) {
            // Handle the button tap here
            cell.Attend.isUserInteractionEnabled = true
            if let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "SendLocationViewController") {
                present(destinationViewController, animated: true, completion: nil)
            }
        }

}

