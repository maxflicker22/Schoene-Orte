//
//  NicePlacesTableViewController.swift
//  Schoene Orte
//
//  Created by Markus Flicker on 07.11.18.
//  Copyright © 2018 Worldcare. All rights reserved.
//

import UIKit

class NicePlacesTableViewController: UITableViewController {
    
    var places: [Place] = []
    var dateFormatter = DateFormatter()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        places.removeAll()
        
        do {
             if let url = Place.placesURL(){ //Dateipfad von Speicherort der Datei holen
       
                let data = try Data(contentsOf: url) //lesen der vorhandenen Datend
                let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) //versuchen aus Array Data-Objekt machen
                
                if let array = plist as? [[String:Any]]{ //überprüfen ob das Objekt wirkich ein Array mit Dictionary ist
                    for dictionary in array { //mit for auf jedes dictionary im Array zugreifen und aus diesen eine Instantz von Place erstellen, anschließend diese Instanz ind das array places speichern
                        let place = Place(dictionary: dictionary)
                        places.append(place)
                    }
                    tableView.reloadData()      //tableview neu laden
                }
                
            }else {
                print(":) Fehler im Dateisystem.")
            }
        }catch {
            print(":) error: \(error)")
        }
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
 

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let office = Place(name: "Max´zu Büro",
//                        website: "Worldcare.org",
//                        phone: "1233545")
//        places.append(office)
//
//        let home = Place(name: "Max´zu Hause")
//        places.append(home)
//
//        let friend = Place(name: "Mani´s Haus", phone:"2348238")
//        places.append(friend)
//
//    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        
        let date = Date(timeIntervalSince1970: place.timestamp)
        cell.detailTextLabel?.text = dateFormatter.string(from: date)
        
        if let imageName = place.imageName {
            let fileURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            
            if let documentURL = fileURLs.first {
                let imageURL = documentURL.appendingPathComponent(imageName)
                
                if let imageData = try? Data(contentsOf: imageURL) { //Bild aus Dateisystem laden
                    let image = UIImage(data: imageData)
                    cell.imageView?.image = image
                }
            }
        }
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //wird aufgerufen kurz bevor der neue ViewController über das Segue auf den Bildschirm geschoben wird; perfekt um letzte vorbereitungen zu treffen.
        if segue.identifier == "showDetail" { //überprüfen um welches segue es sich handelt
            guard let destinationViewController = segue.destination as? DetailViewController else { //Überprüft ob der Typ des übergebenen Viewcontrollers DetailViewController ist //destination hat Typ UIViewController
                print("Der Controller hat nicht den erwarteten Typ")
                return
            }
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { //TableView Fragen nach index der ausgewählten Zelle
                print("Es ist keine Zelle ausgewählt") //überprüft ob eine ZELLE AUSGEWÄHLT ist
                return
            }
            destinationViewController.place = places[selectedIndexPath.row] //auf Property place von detailVC speichern wir Ort der gewählten zeile
            
            //mit guard unwrapen wir schnell ob etwas nil enthält, enthält was nil wird sofort abgebrochen (funktioniert nur bei methode)
            
        }

    }

}
