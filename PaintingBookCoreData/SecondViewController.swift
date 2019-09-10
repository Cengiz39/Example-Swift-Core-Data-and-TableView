//
//  SecondViewController.swift
//  PaintingBookCoreData
//
//  Created by Cengiz Baygın on 9.09.2019.
//  Copyright © 2019 Cengiz Baygın. All rights reserved.
//

import UIKit
import CoreImage
import CoreData
class SecondViewController: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    // Objects
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var editCount = Bool()
    var imageName = UIImage()
    var selectedArtBook = String()
    var selectedId = UUID()
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        imageView.isUserInteractionEnabled = true
        let imagePickGesture = UITapGestureRecognizer.init(target: self, action: #selector(imagePickerFunc))
        imageView.addGestureRecognizer(imagePickGesture)
        let hideKeyboardGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboardFunc))
        view.addGestureRecognizer(hideKeyboardGesture)
        getData()
    }
    // all Func Start Line
    func saveData (){
        let coreDelegate = UIApplication.shared.delegate as! AppDelegate
        let coreContext = coreDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName:"PaintingDB", into: coreContext)
        newPainting.setValue(nameTextField.text, forKey: "name")
        newPainting.setValue(artistTextField.text, forKey: "artist")
        newPainting.setValue(UUID(), forKey: "id")
        if let yearLast = Int(yearTextField.text!){
            newPainting.setValue(yearLast, forKey: "year")
        }
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(imageData, forKey: "image")
        do {
            try coreContext.save()
        } catch  {
            print("Error!")
        }
        NotificationCenter.default.post(name: NSNotification.Name.init("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func hideKeyboardFunc () {
        view.endEditing(true)
    }
    @objc func imagePickerFunc() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        imageName = imageView.image!
        editCount = true
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    func allObjectsClose() {
        nameTextField.isEnabled = false
        artistTextField.isEnabled = false
        yearTextField.isEnabled = false
        imageView.isUserInteractionEnabled = false
        saveButton.isEnabled = false
        
    }
    func allObjectsOpen() {
        nameTextField.isEnabled = true
        artistTextField.isEnabled = true
        yearTextField.isEnabled = true
        imageView.isUserInteractionEnabled = true
        
    }
    func getData () {
        if selectedArtBook != "" {
            allObjectsClose()
            let coreDelegate = UIApplication.shared.delegate as! AppDelegate
            let coreContext = coreDelegate.persistentContainer.viewContext
            let coreFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PaintingDB")
            let idString = selectedId.uuidString
            let corepredictive = NSPredicate.init(format: "id = %@", idString)
            coreFetchRequest.returnsObjectsAsFaults = false
            do {
                let resultsCore =  try coreContext.fetch(coreFetchRequest)
                for resultsArray in resultsCore as! [NSManagedObject] {
                    if let nameTextCorrect = resultsArray.value(forKey: "name") as? String{
                        nameTextField.text = nameTextCorrect
                        informationLabel.text = "Kayıt No:\(idString)"
                    }
                    if let yearCorrect = resultsArray.value(forKey: "year") as? Int{
                        yearTextField.text = "\(yearCorrect)"
                    }
                    if let artistCorrect = resultsArray.value(forKey: "artist") as? String{
                        artistTextField.text = artistCorrect
                    }
                    if let imageCorrect = resultsArray.value(forKey: "image") as? Data{
                        let selectedImage = UIImage.init(data: imageCorrect)
                        imageView.image = selectedImage
                    }
                } // for loop finish
            } catch  {
                print("Error!")
            }
        }
        else {
            allObjectsOpen()
        }
    }
    // MessagesFunc
    func sureAlertFunc(){
        let sureAlert = UIAlertController.init(title: "Bilgileriniz Kaydediliyor...", message: "Girdiğiniz bilfileri kaydetmek için emin misin ?", preferredStyle: UIAlertController.Style.alert)
        let sureOkButton = UIAlertAction.init(title: "Tamam", style: UIAlertAction.Style.cancel) { (UIAlertAction) in
            self.saveData()
        }
        let sureCancelButton = UIAlertAction.init(title: "İptal", style: UIAlertAction.Style.default, handler: nil)
        sureAlert.addAction(sureOkButton)
        sureAlert.addAction(sureCancelButton)
        self.present(sureAlert, animated: true, completion: nil)
    }
    func emptyCorrectFunc(){
        let emptyCorrectMessageAlert = UIAlertController.init(title: "Gerekli Bilgiler Boş!", message: "Gerekli alanları doldurup tekrar dene.", preferredStyle: UIAlertController.Style.alert)
        let  emptyCorrectOkButton = UIAlertAction.init(title: "Tamam", style: UIAlertAction.Style.default) { (UIAlertAction) in
            
        }
        emptyCorrectMessageAlert.addAction(emptyCorrectOkButton)
        self.present(emptyCorrectMessageAlert, animated: true, completion: nil)
    }
    // MessagesFunc Last
    // all Func Last Line
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if nameTextField.text == ""  || yearTextField.text == "" || artistTextField.text == "" {
            emptyCorrectFunc()
        }
        else if saveButton.isEnabled == true || nameTextField.text != "" || yearTextField.text != "" || artistTextField.text != "" || imageView.image != UIImage.init(named: "selectimage"){
            sureAlertFunc()
        }
        
        
    }
}
