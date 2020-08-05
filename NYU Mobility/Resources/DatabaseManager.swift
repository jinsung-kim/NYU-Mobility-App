//
//  DatabaseManager.swift
//  NYU Mobility
//
//  Created by Jin Kim on 8/4/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase

/// Manager object to read and write data to the real time Firebase database
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

extension DatabaseManager {
    
    /// Returns dictionary node at child path
    public func getDataFor(path: String,
                           completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Account Management

extension DatabaseManager {
    
    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch (self) {
            case .failedToFetch:
                return "Database fetching failed"
            }
        }
    }

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
    
    public func getAllClientUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("clients").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public func getAllSpecialistUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("specialists").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    /// Inserts a user into the system
    public func insertClientUser(with user: ClientUser,
                           completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "fullName": user.fullName,
            "code": user.code,
            "username": user.username,
            "password": user.password,
            "mode": "client"
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
                            "password": user.password,
                            "mode": "client"
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
                                "password": user.password,
                                "mode": "client"
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
    
    public func insertSpecialistUser(with user: SpecialistUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "fullName": user.fullName,
            "code": user.code,
            "username": user.username,
            "password": user.password,
            "mode": "specialist"
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
                strongSelf.database.child("specialists").observeSingleEvent(of: .value, with: {
                    snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // Append to user dictionary
                        let newUser = [
                            "fullName": user.fullName,
                            "code": user.code,
                            "username": user.username,
                            "password": user.password,
                            "mode": "specialist"
                        ]
                        usersCollection.append(newUser)
                        
                        // Look for error again when inserting the array
                        strongSelf.database.child("specialists").setValue(usersCollection, withCompletionBlock: { error, _ in
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
                                "password": user.password,
                                "mode": "specialist"
                            ]
                        ]
                        
                        strongSelf.database.child("specialists").setValue(newUserCollection, withCompletionBlock: { error, _ in
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
    let mode: String = "client"
    
    var safeEmail: String {
        var safeEmail = username.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

struct SpecialistUser {
    let fullName: String
    let username: String // email address
    let password: String
    let code: String // Specialist code that will be generated right before
    let mode: String = "specialist"
    
    var safeEmail: String {
        var safeEmail = username.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
