
import UIKit

/**
 * Copyright 2019 Tim Jordan,
 *
 * This software is the intellectual property of the author, and can not be
 * distributed, used, copied, or reproduced, in whole or in part, for any
 * purpose, commercial or otherwise. The author grants the ASU Software
 * Engineering program the right to copy, execute, and evaluate this work for
 * the purpose of determining performance of the author in coursework, and for
 * Software Engineering program evaluation, so long as this copyright and
 * right-to-use statement is kept in-tact in such use. All other uses are
 * prohibited and reserved to the author.<br>
 * <br>
 *
 * Purpose: View controller for UITableView.
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Tim Jordan mailto:tsjorda1@asu.edu
 *         Software Engineering
 * @version November 24, 2019
 */

class PlacesTableViewController: UITableViewController {
  var viewController: ViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewController = tabBarController as? ViewController
    tableView.dataSource = viewController
    viewController?.tableViewController = self

    self.navigationItem.leftBarButtonItem = self.editButtonItem
    
    let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PlacesTableViewController.addPlace))
    self.navigationItem.rightBarButtonItem = addButton
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "PlaceDescriptionSegue") {

      let placeDetailsViewController: PlaceDetailsViewController
        = segue.destination as! PlaceDetailsViewController
      
      let indexPath = self.tableView.indexPathForSelectedRow!

      let tempPlaceDescription: PlaceDescription = PlaceDescription()
      tempPlaceDescription.name = "Loading Place Details..."
      placeDetailsViewController.placeDescription = tempPlaceDescription
      placeDetailsViewController.currentPlaceIndex = indexPath.row

      placeDetailsViewController.placeName =
        viewController?.placeNames[indexPath.row]
    }
  }
  
  @objc func addPlace() {
    print("add button clicked")

    let promptND = UIAlertController(title: "New Place", message: "Enter New Place Name", preferredStyle: UIAlertController.Style.alert)

    promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
    
    promptND.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in
      
      let newPlaceName:String = (promptND.textFields?[0].text == "") ?
        "unknown" : (promptND.textFields?[0].text)!

      let newPlace:PlaceDescription = PlaceDescription()
      newPlace.name = newPlaceName
      
      let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: (self.viewController?.urlString)!)
      let _:Bool = placesConnect.add(placeDescription: newPlace, callback: {(res: String, err: String?) -> Void in
        if err != nil {
          NSLog(err!)
        }else{
          NSLog(res)
          self.viewController?.populatePlaceNames()
        }
      })
      self.tableView.reloadData()
    }))
    promptND.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Place Name"
    })
    present(promptND, animated: true, completion: nil)
  }
}
