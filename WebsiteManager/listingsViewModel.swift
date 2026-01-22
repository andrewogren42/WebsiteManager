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
    private var storage = Storage.storage()
    
    func saveListing() {
        
        guard checkCandlenameIDValid() else {
            statusMessage = "Please enter a valid candle name."
            return
        }
        
        let isNewListing = img.isEmpty
        
        if isNewListing && selectedImage == nil {
            statusMessage = "Error: A photo is requried to create a listing"
            return
        }
        
        if let imageToUpload = selectedImage {
            statusMessage = "Uploading image..."
            uploadImage(image: imageToUpload, fileName: candleID) { [weak self] url in
                guard let self = self else { return }
                if let downloadURL = url {
                    self.img = downloadURL
                    self.performFirestoreSave()
                }
            }
        } else {
            performFirestoreSave()
        }
    }
    
    func deleteListing() {
        
        guard checkCandlenameIDValid() else { return }
        
        statusMessage = "Deleting..."
        
        deleteImage(fileName: candleID) {[weak self] success in
            guard let self = self else { return }
            
            self.db.collection("listings").document(candleID).delete(){ error in
                if let error = error {
                    self.statusMessage = "Error removing document: \(error.localizedDescription)"
                } else {
                    self.statusMessage = "Document successfully removed!"
                    self.clearFields()
                }
            }
            
        }
    }
    
    func performFirestoreSave() {
        var updatedData: [String: Any] = [:]
        
        updatedData["name"] = name
        
        if !priceString.isEmpty, let price = Double(priceString) {
            updatedData["price"] = price
        }
        
        if !img.isEmpty {
            updatedData["img"] = img
        }
        
        if !desc.isEmpty {
            updatedData["desc"] = desc
        }
        
        if !collection.isEmpty {
            updatedData["collection"] = collection
        }
        
        updatedData["sale"] = sale
        
        do {
            try db.collection("listings").document(candleID).setData(updatedData, merge: true)
            self.statusMessage = "Success!"
            self.clearFields()
        } catch let error {
            self.statusMessage = "Firestore Error: \(error.localizedDescription)"
            
        }
    }
    
    func uploadImage(image: UIImage, fileName:String, completion:@escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("candle_images/\(fileName)")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if error != nil {
                completion(nil)
                return
            }
            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
    
    func deleteImage(fileName:String, completion: @escaping (Bool) -> Void) {
        let storageRef = storage.reference().child("candle_images/\(fileName)")
        
        storageRef.delete { error in
            if let error = error {
                self.statusMessage = "Storage Delete Error: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
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
}
