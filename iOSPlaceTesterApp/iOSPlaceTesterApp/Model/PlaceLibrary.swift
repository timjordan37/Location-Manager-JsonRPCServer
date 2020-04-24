import Foundation

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
 * Purpose: Places Library
 *
 * SER 423 see http://quay.poly.asu.edu/Mobile/
 * @author Tim Jordan mailto:tsjorda1@asu.edu
 *         Software Engineering
 * @version November 24, 2019
 */

class PlaceLibrary {
  private var placeDescriptions: [PlaceDescription] = [PlaceDescription]()
  
  init() {

    if let path = Bundle.main.path(forResource: "places", ofType: "json"){
      do {
        let jsonStr:String = try String(contentsOfFile:path)
        let data:Data = jsonStr.data(using: String.Encoding.utf8)!
        let jsonObjDict:[String:Any] = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
        
        if let jsonObjArray = jsonObjDict["placeArray"] as? [Any] {
          for obj in jsonObjArray {
            if let placeDescriptionObj = obj as? [String: Any] {
              placeDescriptions.append(PlaceDescription(jsonObjDict: placeDescriptionObj))
            }
          }
        }
      } catch {
        print("Contents of places.json could not be loaded")
      }
    }
  }
  
  func getPlaceAt(_ index: Int) -> PlaceDescription {
    return placeDescriptions[index]
  }
  
  func getPlaceWithName(_ name: String) -> PlaceDescription {
    for placeDescription in placeDescriptions {
      if (placeDescription.name == name) {
        return placeDescription
      }
    }
    print("PlaceDescription with name " + name + " was not found.")
    return PlaceDescription()
  }
  
  func setPlaceAt(_ index: Int, newPlaceDescription: PlaceDescription) {
    placeDescriptions[index] = newPlaceDescription
  }
  
  func removePlaceAt(_ index: Int) {
    placeDescriptions.remove(at: index)
  }
  
  func addPlace(newPlaceDescription: PlaceDescription) {
    placeDescriptions.append(newPlaceDescription)
  }
  
  func size() -> Int {
    return placeDescriptions.count;
  }
}
