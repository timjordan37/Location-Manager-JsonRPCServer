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
 * Purpose: Place Description
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Tim Jordan mailto:tsjorda1@asu.edu
 *         Software Engineering
 * @version November 24, 2019
 */

class PlaceDescription {
  var name: String = "Unknown"
  var description: String? = ""
  var category: String? = ""
  var addressTitle: String? = ""
  var addressStreet: String? = ""
  var elevation: Double? = 0
  var latitude: Double? = 0
  var longitude: Double? = 0
  
  init() {

  }
  
  init (jsonStr: String) {
    if let data: Data = jsonStr.data(using: String.Encoding.utf8){
      do{
        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:Any]
        self.name = (dict!["name"] as? String)!
        self.description = (dict!["description"] as? String)!
        self.category = (dict!["category"] as? String)!
        self.addressTitle = (dict!["address-title"] as? String)!
        self.addressStreet = (dict!["address-street"] as? String)!
        self.elevation = (dict!["elevation"] as? Double)!
        self.latitude = (dict!["latitude"] as? Double)!
        self.longitude = (dict!["longitude"] as? Double)!
      } catch {
        print("unable to convert to dictionary")
      }
    }
  }
  
  init (jsonObjDict dict: [String:Any]?) {
    self.name = (dict!["name"] as? String)!
    self.description = (dict!["description"] as? String)!
    self.category = (dict!["category"] as? String)!
    self.addressTitle = (dict!["address-title"] as? String)!
    self.addressStreet = (dict!["address-street"] as? String)!
    self.elevation = (dict!["elevation"] as? Double)!
    self.latitude = (dict!["latitude"] as? Double)!
    self.longitude = (dict!["longitude"] as? Double)!
  }
  
  func toJsonString() -> String {
    var jsonStr = "";
    do {
      let jsonData:Data = try JSONSerialization.data(withJSONObject: toJsonObj(), options: JSONSerialization.WritingOptions.prettyPrinted)
      jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
    } catch let error as NSError {
      print(error)
    }
    return jsonStr
  }
  
  func toJsonObj() -> [String:Any] {
    let jObj:[String:Any] = [
      "name": name as Any,
      "description": description as Any,
      "category": category as Any,
      "address-title": addressTitle as Any,
      "address-street": addressStreet as Any,
      "elevation": elevation as Any,
      "latitude": latitude as Any,
      "longitude": longitude as Any,
      ] as [String : Any]
    return jObj
  }
}
