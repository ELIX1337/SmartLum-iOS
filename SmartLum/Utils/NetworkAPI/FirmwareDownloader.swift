//
//  NetworkManager.swift
//  SmartLum
//
//  Created by Tim on 26.02.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import UIKit

class FirmwareDownloader {
    
    let baseURL: String = "http://192.168.10.241:8000"
    let devicesDirectory: String = "/device/api"
    let apiToken: String = "e28f48c8a965a8a67bd8151d1ee6f41ce8d6fe8d"
    
    func checkDeviceForUpdates(with uuid: String, withCompletion completion: @escaping (Device?, ApiError?) -> Void) {
        let url = URL(string: baseURL + devicesDirectory + "/" + uuid + "/")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("iOS \(UIDevice.current.systemVersion)", forHTTPHeaderField: "OS")
        request.addValue("1", forHTTPHeaderField: "Version")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil, nil)
                return
            }
            do {
                let devices: [Device] = try JSONDecoder().decode([Device].self, from: data)
                for device in devices { completion(device, nil) }
            } catch {
                let error: ApiError? = try? JSONDecoder().decode(ApiError.self, from: data)
                completion(nil, error)
                print("API error: \(error?.detail ?? "Unknown API error")")
            }
        }
        task.resume()
    }
    
    func downloadFirmware(from source: URL, withCompletion completion: @escaping (URL?, Error?) -> Void) {
        if let directoryToSaveFile = appSupportDirectoryURL() {
            let destinationURL = directoryToSaveFile.appendingPathComponent(source.lastPathComponent)
            if FileManager().fileExists(atPath: destinationURL.path) {
                print("File already exists \(destinationURL.path)")
                completion(destinationURL, nil)
            } else {
                let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: nil)
                var request = URLRequest(url: source)
                request.httpMethod = "GET"
                let task = session.dataTask(with: request, completionHandler: { data, response, error in
                    if error == nil {
                        if let response = response as? HTTPURLResponse {
                            if response.statusCode == 200 {
                                if let data = data {
                                    if let _ = try? data.write(to: destinationURL, options: Data.WritingOptions.atomic) {
                                        self.disableFileBackup(withURL: destinationURL)
                                        completion(destinationURL, error)
                                    }
                                    else { completion(destinationURL, error) }
                                }
                                else { completion(destinationURL, error) }
                            }
                        }
                    }
                    else { completion(destinationURL, error) }
                })
                task.resume()
            }
        }
    }
    
    func appDocumentsDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func appSupportDirectoryURL() -> URL? {
        var appSupportDirectory: URL?
        do {
            appSupportDirectory = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                  in: .userDomainMask,
                                                                  appropriateFor: nil,
                                                                  create: true)
        } catch {
            print("Failed to read AppSupportDirectory")
        }
        return appSupportDirectory
    }
    
    func appCacheDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func appTmpDirectoryURL() -> URL? {
        return URL(string: NSHomeDirectory())
    }
    
    func disableFileBackup(withURL url: URL) {
        var resourceURL = url
        var resourceValue = URLResourceValues()
        resourceValue.isExcludedFromBackup = true
        do {
            try resourceURL.setResourceValues(resourceValue)
            print("File has been excluded from backup")
        } catch {
            print("Error while excluding file from backup: \(url)")
        }
    }
}

struct Device {
    //let name: String?
    let firmwareVersion: Int?
    let firmwareURL: String?
    let dataCreate: String?
    let category: String?
}

extension Device: Decodable {
    enum CodingKeys: String, CodingKey {
        //case name
        case firmwareVersion = "version"
        case firmwareURL = "softwareFile"
        case dataCreate = "dataCreate"
        case category = "category"
    }
}

struct ApiError: Decodable {
    let detail: String?
}

// For nested JSON
//struct Wrapper: Decodable {
//    let items: [Device]
//}
