//
//  ProfessorSubjectsCollectionView.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/18/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

private let reuseIdentifier = "Cell"

class ProfessorSubjectsCollectionView: UICollectionViewController {

    private var subjects: [[String : String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "ProfessorSubjectsCollectionViewCell", bundle: nil)
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: "ProfessorSubjectsCollectionViewCell")   
        fetchSubjectsFromFirebase()
        
    }
    private func fetchSubjectsFromFirebase() {
        guard let professorEmail = Auth.auth().currentUser?.email else {
            print("Error: Professor not authenticated.")
            return
        }

        let databaseReference = Database.database().reference().child("subjects")

        // Query subjects where the professorEmail matches the 'Professor' field
        let query = databaseReference.queryOrdered(byChild: "Professor").queryEqual(toValue: professorEmail)

        query.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // Data exists, process it
                guard let subjectsData = snapshot.value as? [String: [String: String]] else {
                    print("Invalid subjects data format.")
                    return
                }

                let subjectsArray = subjectsData.values.map { $0 }
                print("Fetched Subjects: \(subjectsArray)")

                self.subjects = subjectsArray
                self.collectionView.reloadData() // Reload the collection view after fetching data
            } else {
                print("No subjects data found.")
            }
        }
    }


    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfessorSubjectsCollectionViewCell", for: indexPath) as! ProfessorSubjectsCollectionViewCell

        let subject = subjects[indexPath.item]
        cell.NameLabela.text = subject["name"]
        cell.TopicLabela.text = subject["topic"]
        cell.colorView.backgroundColor = UIColor.systemPink

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("Number of Subjects: \(subjects.count)")

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
