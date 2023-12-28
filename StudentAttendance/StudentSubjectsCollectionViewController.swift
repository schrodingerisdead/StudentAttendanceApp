//
//  StudentSubjectsCollectionViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/20/23.
//
import UIKit
import FirebaseDatabase
import FirebaseAuth

private let reuseIdentifier = "Cell"

struct EnrolledSubject {
    var subjectId: String?
    var name: String
    var topic: String
    // Add other properties as needed
}

class StudentSubjectsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var enrolledSubjects: [EnrolledSubject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEnrolledSubjectsFromFirebase()

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // Adjust the itemSize to your desired size
            flowLayout.itemSize = CGSize(width: 150, height: 150)
        }

        let cellNib = UINib(nibName: "StudentSubjectsCollectionViewCell", bundle: nil)
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: "StudentSubjectsCollectionViewCell")
    }
    private func fetchEnrolledSubjectsFromFirebase() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: User not authenticated.")
            return
        }

        let enrolledSubjectsRef = Database.database().reference().child("enrolled_subjects")

        enrolledSubjectsRef.observeSingleEvent(of: .value) { snapshot in
            guard let enrolledSubjectsData = snapshot.value as? [String: [String: Bool]] else {
                print("No enrolled subjects data found.")
                print("Enrolled Subjects Snapshot: \(snapshot)")
                return
            }

            // Extract subject names from the dictionary
            let subjectNames = enrolledSubjectsData.keys

            // Fetch subject details using subject names
            self.fetchSubjectDetails(userEmail: userEmail, subjectNames: Set(Array(subjectNames)))
        }
    }

    private func fetchSubjectDetails(userEmail: String, subjectNames: Set<String>) {
        let subjectsRef = Database.database().reference().child("subjects")

        subjectsRef.observeSingleEvent(of: .value) { snapshot in
            guard let subjectsData = snapshot.value as? [String: [String: Any]] else {
                print("No subjects data found.")
                print("Subjects Snapshot: \(snapshot)")
                return
            }

            self.enrolledSubjects = subjectsData.compactMap { (key, value) in
                guard let subjectName = value["name"] as? String,
                      let topic = value["topic"] as? String,
                      subjectNames.contains(subjectName) else {
                    return nil
                }

                var enrolledSubject = EnrolledSubject(
                    subjectId: key,  // You can use the subject ID here if needed
                    name: subjectName,
                    topic: topic
                    // Add other properties as needed
                )

                return enrolledSubject
            }

            self.collectionView.reloadData()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudentSubjectsCollectionViewCell", for: indexPath) as! StudentSubjectsCollectionViewCell

        let enrolledSubject = enrolledSubjects[indexPath.item]

        cell.SubjectName.text = enrolledSubject.name
        cell.SubjectTopic.text = enrolledSubject.topic
        cell.colorView.backgroundColor = UIColor.systemTeal

        return cell
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return enrolledSubjects.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}

