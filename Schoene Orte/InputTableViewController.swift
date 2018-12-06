//
//  InputTableViewController.swift
//  Schoene Orte
//
//  Created by Markus Flicker on 07.11.18.
//  Copyright © 2018 Worldcare. All rights reserved.
//

import UIKit
import CoreLocation

class InputTableViewController: UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var websiteTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self//Instanz der Klasse InputViewController  weisen wir der delegate Property des LocationManager zu
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestLocationService()

    }
    func requestLocationService(){
        guard CLLocationManager.locationServicesEnabled() else{
            print("location service not enabled")
            return
        }
        guard CLLocationManager.authorizationStatus() != .restricted else{
            print("Restricted")
            return
        }
        guard CLLocationManager.authorizationStatus() != .denied else{
            print("Denied")
            return
        }               //1.Überprüfen ob Nutzer bei vorherigen Nutzung abgelehnt hat, der app die Standortinformation zu geben
        if CLLocationManager.authorizationStatus() == .notDetermined {
            print("NotDetermined")
            locationManager.requestWhenInUseAuthorization() //2. nach Berechtigung fragen
        } else {
            print("Something else")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse){    // wird aufgerufen wenn User die Nutzung der
                                                //Standortdaten zu oder abgelehnt hat
            print("AuthorizedWheninUse")
            locationManager.startUpdatingLocation() //wenn er zugestimmt hat -> Standortbestimmung wir initiiert
        }
        print("didChangeAuthorizationStatus: \(status)") //wenn er nicht zugestimmt hat
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Wenn LocationManager den Standort ermittelt hat wird diese Methode aufgerufen
        if let location = locations.last { // der Letzte Ort ist der genaueste; Wird immer wieder ausgeführt wenn neue Informationen über Standort verfügbar sind
            print(":) Standort: \(location)") //zweiter Parameter ist ein Array und enthält die ermittelten Orte
            self.location = location //ermittelte location wird auf der InputViewController Property location gesetzt
            
            locationManager.stopUpdatingLocation() //wir teilen Manager mit das er aufhören kann neuen Standort zu ermitteln
        }
    }//3. Delegate Methoden implementieren damnit man auf das Ergebnis des Location-Managers reagieren kann
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 { //Wenn 4. Zelle gedrüdckt wird
            let imagePicker = UIImagePickerController() //ImagePicker wird erstellt
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil) //Imagepicker wird angezeigt
            
        }
    }
    
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {//sobald User bild ausgewählt hat wird diese Methode aufgerufen
                                                //Das bild wird im INFO dictionary an die Delegate Methode übergeben
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage //Mit dem Schlüssel UIImagePickerController erhalten wir das Originalbild
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        if let name = nameTextfield.text {
            
            let timestamp = Date().timeIntervalSince1970
            var imageName: String? = nil
            
            if let image = imageView.image { //Wenn Foto im imageView ist
                imageName = "\(Int(timestamp)).jpg" //Name des Bildes
                let imageData = image.jpegData(compressionQuality: 0.01) //Bild wird in Jpeg verwandelt und komprimiert
                let fileURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) //File URLs holen
            
                if let documentURL = fileURLs.first { //Dokumentverzeichnis Url holen
                    let imageURL = documentURL.appendingPathComponent(imageName!) //Name an URL anfügen
                    
                    print(imageURL)
                    _ = try? imageData?.write(to: imageURL, options: [.atomic]) //Datei(Dateiname) in Verzeichnis schreiben
                }
            }
            let place = Place(name: name, imageName: imageName, website: websiteTextfield.text, phone: phoneTextfield.text, coordinate: location?.coordinate)
            
            print(":) place: \(place)")
            let plistDictionary = place.plistDictionary()
             print(":) plistDictionary: \(plistDictionary)")
            
           // let plistArray = [plistDictionary]                  //schreiben der Daten ins Dateisystem
            
            if let url = Place.placesURL(){
            let plist: Any?
            if let inData = try? Data(contentsOf: url){
                plist = try? PropertyListSerialization.propertyList(from: inData, options: [], format: nil)
            }else {
                plist = nil
                }
            
            do {
                var plistArray: [[String:Any]] = []
                if let theArray = plist as? [[String:Any]] {
                    plistArray = theArray
                }
                plistArray.append(plistDictionary)
                
                let data = try PropertyListSerialization.data(fromPropertyList: plistArray, format: .xml, options: 0)
                
                try data.write(to: url, options: .atomic)
                
                dismiss(animated: true, completion: nil)
            } catch {
                print(":) error: \(error)")
                }
                } else {
                    print(":) Fehler im Dateisystem")
                }
                
                
            
//            do {
//                let data = try PropertyListSerialization.data(fromPropertyList: plistArray, format: .xml,
//                                                              options: 0) //versuchen aus Array Data-Objekt machen
//
//                if let url = Place.placesURL(){ // Dateipfad/URL holen
//
//                    try data.write(to: url, options: .atomic)                   //versuchen die Plist Datei ins
//                                                                                //Datei-System zu schreiben
//                    dismiss(animated: true, completion: nil)                    //alles erfolgreich dann schließen
//                } else {
//                    print(":-) Fehler im Dateisystem.")
//                }
//            } catch {           //253 stehen geblieben, Auslesen der Dateien!!
//                print(":-) error: \(error)")
//            }
        }
    }
}
