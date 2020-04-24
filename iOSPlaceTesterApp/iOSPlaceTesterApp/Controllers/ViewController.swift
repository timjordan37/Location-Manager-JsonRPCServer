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
 * Purpose: Provides the main functionality for the app.
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Tim Jordan mailto:tsjorda1@asu.edu
 *         Software Engineering
 * @version November 24, 2019
 */

class ViewController: UITabBarController, UITableViewDataSource, UIPickerViewDataSource {
  
  var placeNames: [String] = [String]()
  var tableViewController: PlacesTableViewController?
  
  var urlString = "http://127.0.0.1:8080"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    placeNames.append("Loading places...")
    urlString = generateURL()
    populatePlaceNames()
  }
  
  func generateURL () -> String {
    var serverhost:String = "localhost"
    var jsonrpcport:String = "8080"
    var serverprotocol:String = "http"
    if let path = Bundle.main.path(forResource: "ServerInfo", ofType: "plist"){
      if let dict = NSDictionary(contentsOfFile: path) as? [String:AnyObject] {
        serverhost = (dict["server_host"] as? String)!
        jsonrpcport = (dict["jsonrpc_port"] as? String)!
        serverprotocol = (dict["server_protocol"] as? String)!
      }
    }
    print("setURL returning: \(serverprotocol)://\(serverhost):\(jsonrpcport)")
    return "\(serverprotocol)://\(serverhost):\(jsonrpcport)"
  }
  
  func populatePlaceNames() {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
    let _:Bool = placesConnect.getNames{(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      }else{
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do{
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            self.placeNames = (dict!["result"] as? [String])!
            self.tableViewController?.tableView.reloadData()
          } catch {
            print("unable to convert to dictionary")
          }
        }
      }
    }
  }
  
  func modifyPlace(placeDescription: PlaceDescription) {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
    let _:Bool = placesConnect.remove(name: placeDescription.name, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      }else{
        NSLog(res)
        self.addAfterRemovingPlace(placeDescription: placeDescription)
      }
    })
  }
  
  private func addAfterRemovingPlace(placeDescription: PlaceDescription) {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
    let _:Bool = placesConnect.add(placeDescription: placeDescription, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      }else{
        NSLog(res)
      }
    })
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return placeNames.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placeNames.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Get and configure the cell...
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
    cell.textLabel?.text = placeNames[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    print("tableView editing row at: \(indexPath.row)")
    if editingStyle == .delete {

      let placeName: String = placeNames[indexPath.row]
      
      placeNames.remove(at: indexPath.row)

      let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
      let _:Bool = placesConnect.remove(name: placeName, callback: {(res: String, err: String?) -> Void in
        if err != nil {
          NSLog(err!)
        }else{
          NSLog(res)
        }
      })

      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}
