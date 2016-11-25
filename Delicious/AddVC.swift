//
//  AddVC.swift
//  Delicious
//
//  Created by Fomin Nickolai on 11/23/16.
//  Copyright © 2016 Fomin Nickolai. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Firebase

class AddVC: UIViewController, UINavigationControllerDelegate {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "food-3")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var saveBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveButton))
        button.tintColor = .white
        return button
    }()
    
    let cellImageId = "cellId"
    let cellTitleId = "cellTitleId"
    let cellIngridientsId = "cellIngridientsId"
    let cellInstructionsId = "cellInstructionsId"
    
    let propertiesArray = ["title", "timeToCook", "personCount", "ingridients", "instructions"]
    
    var recipeToSend: [String: String] = [:] {
        didSet {
            for key in propertiesArray {
                if recipeToSend[key] == nil || recipeToSend[key] == "" {
                    print(recipeToSend)
                    saveBarButton.isEnabled = false
                    return
                }
            }
            print(recipeToSend)
            saveBarButton.isEnabled = true
        }
    }
    
    var imageRecipe: UIImage?
    
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = saveBarButton
        saveBarButton.isEnabled = false
        
        view.addSubview(imageView)
        view.addSubview(blurView)
        view.addSubview(collectionView)
        
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        blurView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blurView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.backgroundColor = .clear
        collectionView.register(AddImageCell.self, forCellWithReuseIdentifier: cellImageId)
        collectionView.register(AddTitleCell.self, forCellWithReuseIdentifier: cellTitleId)
        collectionView.register(AddIngrideintsCell.self, forCellWithReuseIdentifier: cellIngridientsId)
        collectionView.register(AddInstructionsCell.self, forCellWithReuseIdentifier: cellInstructionsId)
    }
    
    deinit {
        print("AddVC Deinit")
    }
    
}

//MARK: Actions
extension AddVC {
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleSaveButton() {
        
        let alertController = UIAlertController(title: "Great", message: "Successfully Saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            
            DispatchQueue.main.async(execute: { 
                _ = self.navigationController?.popToRootViewController(animated: true)
            })
            
        })
        
        alertController.addAction(okAction)
        
        if let image = imageRecipe {
            uploadToFirebaseStorageUsingImage(image: image, completion: { imageUrl in
                self.recipeToSend["recipeImage"] = imageUrl
                self.saveRicepeToDatabase(properties: self.recipeToSend, completion: { 
                    self.present(alertController, animated: true, completion: nil)
                })
            })
        }
    }
    
    fileprivate func saveRicepeToDatabase(properties: [String: String], completion: @escaping () -> ()) {
        var baseRef: FIRDatabaseReference
        let ref = DataService.ds.REF_POSTS
        guard let fromId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let timeStamp = String(Int(Date().timeIntervalSince1970))
    
        var values: [String: AnyObject] = ["fromId": fromId as AnyObject, "timestamp": timeStamp as AnyObject, "likes" : 0 as AnyObject]
        
        properties.forEach { (key, value) in
            values[key] = value as AnyObject?
        }
        
        if recipe != nil {
            guard let key = recipe?.recipeId else {
                return
            }
            baseRef = ref.child(key)
        } else {
            baseRef = ref.childByAutoId()
        }
        baseRef.updateChildValues(values, withCompletionBlock: {(error, ref) in
            
            if error != nil {
                return
            }
            completion()
        })
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = DataService.ds.REF_POST_IMAGES.child(imageName)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        if let uploadData = UIImageJPEGRepresentation(image, 0.5) {
            ref.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                
                if error != nil {
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
            })
        }
        
    }
    
}

//MARK: UICollectionViewDataSource
extension AddVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellImageId, for: indexPath) as! AddImageCell
            cell.addVC = self
            if recipe != nil {
                cell.uploadImageView.loadImageUsingCacheWithUrlString(urlString: (recipe?.recipeImage)!)
            }
            return cell
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTitleId, for: indexPath) as! AddTitleCell
            cell.cellTitle.delegate = self
            cell.cellTitle.tag = 1
            cell.timeToCook.delegate = self
            cell.timeToCook.tag = 2
            cell.personCount.delegate = self
            cell.personCount.tag = 3
            if recipe != nil {
                cell.cellTitle.text = recipe?.title
                cell.timeToCook.text = recipe?.timeToCook
                cell.personCount.text = recipe?.personCount
            }
            return cell
        } else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIngridientsId, for: indexPath) as! AddIngrideintsCell
            cell.textView.delegate = self
            cell.textView.tag = 1
            if recipe != nil {
                cell.textView.text = recipe?.ingridients
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellInstructionsId, for: indexPath) as! AddInstructionsCell
            cell.textView.delegate = self
            cell.textView.tag = 2
            if recipe != nil {
                cell.textView.text = recipe?.instructions
            }
            return cell
        }
    }
}
//MARK: UITextFieldDelegate
extension AddVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            recipeToSend["title"] = textField.text!
        case 2:
            recipeToSend["timeToCook"] = textField.text!
        case 3:
            recipeToSend["personCount"] = textField.text!
        default:
            break
        }
    }
}
//MARK: UITextViewDelegate
extension AddVC: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        switch textView.tag {
        case 1:
            recipeToSend["ingridients"] = textView.text!
        case 2:
            recipeToSend["instructions"] = textView.text!
        default:
            break
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension AddVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 0
        if indexPath.item == 0 {
            height = 244
        } else if indexPath.item == 1 {
            height =  103
        } else {
            height = 300
        }
        return CGSize(width: view.frame.width - 20, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(75, 0, 0, 0)
        
    }
    
}
//MARK: UIImagePickerControllerDelegate
extension AddVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //we selected a video
            //handleVideoSelectedForUrl(url: videoUrl)
            
        } else {
            handleImageSelectedForInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleImageSelectedForInfo(info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage]  as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            let indexPath = IndexPath(item: 0, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as! AddImageCell
            cell.setImage = selectedImage
            imageRecipe = selectedImage
        }
    }
}
