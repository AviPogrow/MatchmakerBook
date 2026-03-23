//
//  ImageUploadService.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 3/22/26.
//  Copyright © 2026 user. All rights reserved.

import UIKit
import Firebase

final class ImageUploadService {
    
    static let shared = ImageUploadService()
    
    private init() {}
    
    func uploadImage(
        _ image: UIImage,
        folder: String = "test_girl_profile_images",
        compressionQuality: CGFloat = 0.1,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let uploadData = image.jpegData(compressionQuality: compressionQuality) else {
            completion(.failure(ImageUploadError.failedToCreateJPEGData))
            return
        }
        
        let filename = UUID().uuidString
        let storageRef = Storage.storage()
            .reference()
            .child(folder)
            .child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                guard let urlString = url?.absoluteString else {
                    completion(.failure(ImageUploadError.missingDownloadURL))
                    return
                }
                
                completion(.success(urlString))
            }
        }
    }
}

enum ImageUploadError: Error {
    case failedToCreateJPEGData
    case missingDownloadURL
}
