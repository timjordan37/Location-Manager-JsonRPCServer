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
 * Purpose: Place details view controller
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Tim Jordan mailto:tsjorda1@asu.edu
 *         Software Engineering
 * @version November 24, 2019
 */

class PlaceDetailsViewController: UIViewController {
  var placeDescription: PlaceDescription?
  var viewController: ViewController?
  var placeName: String?
  var currentPlaceIndex: Int?
  
  @IBOutlet weak var placeNameTextField: UITextField!
  @IBOutlet weak var placeDescriptionTextField: UITextField!
  @IBOutlet weak var placeCategoryTextField: UITextField!
  @IBOutlet weak var placeAddressTitleTextField: UITextField!
  @IBOutlet weak var placeAddressStreetTextField: UITextField!
  @IBOutlet weak var placeElevationTextField: UITextField!
  @IBOutlet weak var placeLatitudeTextField: UITextField!
  @IBOutlet weak var placeLongitudeTextField: UITextField!
  @IBOutlet weak var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
 
    viewController = tabBarController as? ViewController
    
    getPlaceDescription()

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                   name: UIResponder.keyboardWillHideNotification,
                                   object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                   name: UIResponder.keyboardWillChangeFrameNotification,
                                   object: nil)
  }
  
  func getPlaceDescription() {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: viewController!.urlString)
    let _:Bool = placesConnect.get(name: placeName!, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      }else{
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do{
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
            self.placeDescription = PlaceDescription(jsonObjDict: aDict)
            self.hydratePlaceDescriptionViews()
          } catch {
            print("unable to convert to dictionary")
          }
        }
      }
    })
  }
  
  @objc func adjustForKeyboard(notification: Notification) {
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == UIResponder.keyboardWillHideNotification {
      scrollView.contentInset = .zero
    } else {
      scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    scrollView.scrollIndicatorInsets = scrollView.contentInset
  }
  
  private func hydratePlaceDescriptionViews() {
    placeNameTextField.text = placeDescription?.name
    placeDescriptionTextField.text = placeDescription?.description
    placeCategoryTextField.text = placeDescription?.category
    placeAddressTitleTextField.text = placeDescription?.addressTitle
    placeAddressStreetTextField.text = placeDescription?.addressStreet
    placeElevationTextField.text = String(format: "%f",(placeDescription?.elevation)!)
    placeLatitudeTextField.text = String(format: "%f",(placeDescription?.latitude)!)
    placeLongitudeTextField.text = String(format: "%f",(placeDescription?.longitude)!)
  }
  
  @IBAction func onDonePress(_ sender: UIButton) {
    placeDescription?.description = placeDescriptionTextField.text
    placeDescription?.category = placeCategoryTextField.text
    placeDescription?.addressTitle = placeAddressTitleTextField.text
    placeDescription?.addressStreet = placeAddressStreetTextField.text
    placeDescription?.elevation = (placeElevationTextField.text! as NSString).doubleValue
    placeDescription?.latitude = (placeLatitudeTextField.text! as NSString).doubleValue
    placeDescription?.longitude = (placeLongitudeTextField.text! as NSString).doubleValue

    viewController?.modifyPlace(placeDescription: self.placeDescription!)

    self.navigationController?.popViewController(animated: true)
  }
}
