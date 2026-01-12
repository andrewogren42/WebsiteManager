//
//  listingsViewModel.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/11/26.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit

class ListingsViewModel: ObservableObject{
    @Published var name: String = ""
    @Published var priceString:String = ""
    @Published var img: String = ""
    @Published var desc: String = ""
    @Published var collection: String = ""
    @Published var sale: Bool = false
    @Published var statusMessage: String = ""
    @Published var candleID: String = ""
    @Published var selectedImage: UIImage?
    
    private var db = Firestore.firestore()
    
    func saveListing() {
        
        guard checkCandlenameIDValid() else {
            statusMessage = "Please enter a valid candle name."
            return
        }
        
        guard let imageToUpload = selectedImage else {
            statusMessage = "Error: You must select a picture before saving."
            return
        }
        
        statusMessage = "Uploading image..."
        
        uploadImage(image: imageToUpload) { [weak self] url in
            guard let self = self else { return }
            
            if let downloadURL = url {
                // 2. Success! Set the URL string to our img property
                self.img = downloadURL
                self.performFirestoreSave()
            } else {
                self.statusMessage = "Image upload failed."
            }
        }
    }
    
    func performFirestoreSave() {
        let newListing = Listing(
            name: name,
            price: Double(priceString) ?? 0.0,
            img: img, // This now has the real URL from Firebase
            desc: desc,
            collection: collection,
            sale: sale
        )
        
        do {
            try db.collection("listings").document(candleID).setData(from: newListing)
            statusMessage = "Successfully created \(name) Listing!"
            clearFields()
        } catch let error {
            statusMessage = "Error writing to Firestore: \(error.localizedDescription)"
        }
    }
    
    func editListing() {
        
        if checkCandlenameIDValid() {
            var updatedData: [String: Any] = [:]
            if !priceString.isEmpty {
                guard let p = Double(priceString) else{
                    self.statusMessage = "Invalid Price Input, Only Numbers"
                    return
                }
                updatedData["price"] = p
            }
            if !desc.isEmpty { updatedData["desc"] = desc}
            if !img.isEmpty { updatedData["img"] = img}
            if !collection.isEmpty { updatedData["collection"] = collection}
            updatedData["sale"] = sale
            
            db.collection("listings").document(candleID).updateData(updatedData) { error in
                if let error = error {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                } else {
                    self.statusMessage = "Successfully Updated!"
                    self.clearFields()
                }
            }
        }
    }
    
    func deleteListing() {
        
        if checkCandlenameIDValid() {
            
            db.collection("listings").document(candleID).delete(){ error in
                if let error = error {
                    self.statusMessage = "Error removing document: \(error)"
                } else {
                    self.statusMessage = "Document successfully removed!"
                    self.clearFields()
                }
            }
        }
    }
    func clearFields() {
            name = "";
            priceString = "";
            img = "";
            desc = "";
            collection = "";
            sale = false;
            candleID = ""
        }
    
    func checkCandlenameIDValid() -> Bool {
        if name.isEmpty {
            return false
        }
        candleID = name.lowercased()
                        .replacingOccurrences(of: " ", with: "")
        return true
    }
    
    func uploadImage(image: UIImage, completion: @escaping (String?) -> Void) {
        // 1. Compress the image to save space (Stay under that free limit!)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        // 2. Create a unique filename
        let fileName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("candle_images/\(fileName)")
        
        // 3. Start the upload
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 4. Get the Download URL (This is what you save to Firestore)
            storageRef.downloadURL { url, error in
                if let downloadURL = url?.absoluteString {
                    completion(downloadURL)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
