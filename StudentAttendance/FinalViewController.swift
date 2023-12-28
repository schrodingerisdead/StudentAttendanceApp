//
//  FinalViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/21/23.
//

import UIKit
import MapKit
import FirebaseDatabase
class FinalViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var StudentMap: MKMapView!
    var studentLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                StudentMap.showsUserLocation = true        // Do any additional setup after loading the view.
    }
    
    @IBAction func AcceptClicked(_ sender: Any) {
        let attendanceRef = Database.database().reference().child("Attendance").childByAutoId()
                let attendanceData: [String: Any] = [
                    "studentEmail": "student@example.com", // Replace with the actual student's email
                    "latitude": studentLocation.latitude,
                    "longitude": studentLocation.longitude,
                    "status": "Present", // You can set the initial status as "Present" when the professor accepts
                    "timestamp": ServerValue.timestamp() // Firebase timestamp
                ]

                attendanceRef.setValue(attendanceData) { (error, ref) in
                    if let error = error {
                        print("Error creating attendance record: \(error.localizedDescription)")
                    } else {
                        print("Attendance record created successfully.")
                    }
                }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let studentCoordinate = manager.location?.coordinate {
               studentLocation = studentCoordinate
               let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
               let region = MKCoordinateRegion(center: studentLocation, span: span)
               StudentMap.setRegion(region, animated: true)

               StudentMap.removeAnnotations(StudentMap.annotations)
               let studentAnnotation = MKPointAnnotation()
               studentAnnotation.coordinate = studentLocation
               studentAnnotation.title = "Student location"
               StudentMap.addAnnotation(studentAnnotation)
           }
       }
  
    
     @IBAction func DeclineClicked(_ sender: Any) {
        let studentEmail = "student@example.com" // Replace with the actual student's email

           // Query the Firebase database to find the attendance record
           Database.database().reference().child("Attendance")
               .queryOrdered(byChild: "studentEmail")
               .queryEqual(toValue: studentEmail)
               .observeSingleEvent(of: .value) { (snapshot) in
                   for child in snapshot.children {
                       if let attendanceSnapshot = child as? DataSnapshot {
                           // Use the key directly, as it's a non-optional string
                           let attendanceKey = attendanceSnapshot.key

                           // Remove the attendance record from Firebase
                           Database.database().reference().child("Attendance").child(attendanceKey).removeValue { (error, _) in
                               if let error = error {
                                   print("Error deleting attendance record: \(error.localizedDescription)")
                               } else {
                                   print("Attendance record deleted successfully.")
                                   // Display a local notification that the request has been declined
                                   let notificationCenter = UNUserNotificationCenter.current()
                                   let content = UNMutableNotificationContent()
                                   content.title = "Attendance Declined"
                                   content.body = "The attendance request has been declined."
                                   let request = UNNotificationRequest(identifier: "attendanceDeclined", content: content, trigger: nil)
                                   notificationCenter.add(request) { (error) in
                                       if let error = error {
                                           print("Error displaying local notification: \(error.localizedDescription)")
                                       }
                                   }
                               }
                           }
                       }
                   }
               }
     }
}
