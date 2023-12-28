//
//  SendLocationViewController.swift
//  StudentAttendance
//
//  Created by Magdalena Oreshkova on 12/20/23.
//
import FirebaseDatabase
import FirebaseAuth
import UIKit
import MapKit

class SendLocationViewController: UIViewController, ScheduleTableViewCellDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var StudentMap: MKMapView!
    @IBOutlet weak var SendLocation: UIButton!
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    @IBAction func SendLocationClicked(_ sender: Any) {
        guard let userLocation = locationManager.location?.coordinate else {
                    print("Error: Unable to get user location.")
                    return
                }

                // Save the location to Firebase
                saveLocationToFirebase(location: userLocation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let studentCoord = manager.location?.coordinate {
                let studentCenter = CLLocationCoordinate2D(latitude: studentCoord.latitude, longitude: studentCoord.longitude)

                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: studentCenter, span: span)
                StudentMap.setRegion(region, animated: true)

                StudentMap.removeAnnotations(StudentMap.annotations)
                let studentAnnotation = MKPointAnnotation()
                studentAnnotation.coordinate = studentCenter
                studentAnnotation.title = "Your location"
                StudentMap.addAnnotation(studentAnnotation)
            }
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            } else {
                // Handle other cases, e.g., show an alert or guide the user to enable location services
                print("Location services not authorized.")
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error.localizedDescription)")
        }

        // MARK: - Table View Delegate

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell

            // Set the delegate for the cell
            cell.delegate = self

            // Configure the cell...

            return cell
        }

        // MARK: - Schedule Table View Cell Delegate

        func didTapAttendButton(in cell: ScheduleTableViewCell) {
            // Use the delegate method to handle the button tap
            cell.Attend.isUserInteractionEnabled = true
            if let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "SendLocationViewController") {
                present(destinationViewController, animated: true, completion: nil)
            }
            print("Button tapped in cell")
        }

        // MARK: - Firebase Integration

        func saveLocationToFirebase(location: CLLocationCoordinate2D) {
            guard let userEmail = Auth.auth().currentUser?.email else {
                print("Error: User not authenticated.")
                return
            }

            let locationUpdate = ["email": userEmail, "lat": location.latitude, "lon": location.longitude] as [String: Any]

            Database.database()
                .reference()
                .child("StudentLocations")
                .childByAutoId()
                .setValue(locationUpdate) { (error, ref) in
                    if let error = error {
                        print("Error saving location to Firebase: \(error.localizedDescription)")
                    } else {
                        print("Location saved successfully.")
                    }
                }
        }
    }
