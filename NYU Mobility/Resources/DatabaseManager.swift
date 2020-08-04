//
//  DatabaseManager.swift
//  NYU Mobility
//
//  Created by Jin Kim on 8/4/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    // Referenced throughout view controllers
    static let shared = DatabaseManager()
    
    // Reference to the database
    private let database = Database.database().reference()
    
    static func safeEmail(_ emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: - Account Management

extension DatabaseManager {
    
    /**
        Checks to see if a user was already inserted into the system -> in which it would return true
        - Parameters:
            - username: The target  username/email to look for
            - completion: Async closure to return with result of observer
     */
    public func userExists(with username: String,
                           completion: @escaping ((Bool) -> Void)) {
        let safeEmail = DatabaseManager.safeEmail(username)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Inserts a user into the system
    public func insertUser(with user: ClientUser,
                           completion: @escaping (Bool) -> Void) {
        print(user.safeEmail)
        print(user.username)
        database.child(user.safeEmail).setValue([
            "fullName": user.fullName,
            "code": user.code,
            "username": user.username,
            "password": user.password
            ], withCompletionBlock: {
                [weak self] error, _ in
                guard let strongSelf = self else {
                    return
                }
                // Error inserting child
                guard error == nil else {
                    print("Failed to write to database")
                    completion(false)
                    return
                }
                strongSelf.database.child("clients").observeSingleEvent(of: .value, with: {
                    snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // Append to user dictionary
                        let newUser = [
                            "fullName": user.fullName,
                            "code": user.code,
                            "username": user.username,
                            "password": user.password
                        ]
                        usersCollection.append(newUser)
                        
                        // Look for error again when inserting the array
                        strongSelf.database.child("clients").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            // User inserted successfully
                            completion(true)
                        })
                    } else {
                        // No users in that array -> create that array
                        let newUserCollection: [[String: String]] = [
                            [
                                "fullName": user.fullName,
                                "code": user.code,
                                "username": user.username,
                                "password": user.password
                            ]
                        ]
                        
                        strongSelf.database.child("clients").setValue(newUserCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                // Error creating array within document
                                completion(false)
                                return
                            }
                            
                            // Collection created successfully
                            completion(true)
                        })
                    }
                })
            }
        )
    }
}

struct ClientUser {
    let fullName: String
    let username: String // email address
    let password: String
    let code: String // Specialist code
    
    var safeEmail: String {
        var safeEmail = username.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
