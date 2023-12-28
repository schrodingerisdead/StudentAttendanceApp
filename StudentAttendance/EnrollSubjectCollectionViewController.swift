//
//  EnrollSubjectCollectionViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/18/23.
//

import UIKit
import FirebaseDatabase


struct Subject {
    var subjectId: String?
    var name: String
    var topic: String
    var professor: String
    // Add other properties as needed
}
private let reuseIdentifier = "Cell"

class EnrollSubjectCollectionViewController: UICollectionViewController {
    
    var subjects: [Subject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSubjectsFromFirebase()        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
           // Register cell classes
        let cellNib = UINib(nibName: "EnrollSubjectCollectionViewCell", bundle: nil)
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: "EnrollSubjectCollectionViewCell")


        // Do any additional setup after loading the view.
    }
    
    
    private func fetchSubjectsFromFirebase() {
        let databaseReference = Database.database().reference().child("subjects")

        databaseReference.observeSingleEvent(of: .value) { snapshot in
            guard let subjectsData = snapshot.value as? [String: [String: Any]] else {
                return
            }

            self.subjects = subjectsData.map { (key, value) in
                var subject = Subject(
                    subjectId: key,  // Accessing the subjectId (key) from Firebase
                    name: value["name"] as? String ?? "",
                    topic: value["topic"] as? String ?? "",
                    professor: value["professor"] as? String ?? ""
                    // Add other properties as needed
                )
                return subject
            }

            // Print the subjects, including subjectId
            for subject in self.subjects {
                print("Subject ID: \(subject.subjectId ?? "No ID"), Name: \(subject.name), Topic: \(subject.topic), Professor: \(subject.professor)")
            }

            self.collectionView.reloadData()
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnrollSubjectCollectionViewCell", for: indexPath) as! EnrollSubjectCollectionViewCell

        let subject = subjects[indexPath.item]

        // Set the subjectId for the cell
        cell.subjectId = subject.subjectId

        cell.SubjectName.text = subject.name
        cell.SubjectTopic.text = subject.topic
        
        return cell
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return subjects.count
    }

 

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
