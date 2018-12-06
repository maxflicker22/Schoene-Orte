//
//  DetailViewController.swift
//  Schoene Orte
//
//  Created by Markus Flicker on 27.11.18.
//  Copyright © 2018 Worldcare. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    var place: Place? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let thePlace = place else { return } //überprüfen das nicht nil enthalten ist
        print(place as Any)
        label.text = thePlace.name

        // Do any additional setup after loading the view.
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
