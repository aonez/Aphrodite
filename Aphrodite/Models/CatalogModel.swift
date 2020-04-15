//
//  CatalogModel.swift
//  Aphrodite
//
//  Copyright © 2020 Joey. All rights reserved.
//

import SwiftUI
import CoreServices


public var carPathLookup: [String:String] = [:]

#if !targetEnvironment(simulator)
public let docURL: URL = URL(fileURLWithPath: "/var/mobile/Documents/Aphrodite", isDirectory: true)
#else
public let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
#endif

class CatalogModel: ObservableObject {
    
    @Published var AppCARs = [AssetCatalog]()
    @Published var CCCARs = [AssetCatalog]()
    @Published var FrameworkCARs = [AssetCatalog]()
    
    
    init() {
        
        #if targetEnvironment(macCatalyst)
        macOSFetch()
        #else
        iOSFetch()
        #endif
        
        populateCarPathLookup()
        shuffleCARArrays()
    }
    
    
    private func iOSFetch() {
        
        let fm = FileManager.default
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "Aphrodite-ThreadSafeSerialQueue", qos: .userInteractive)

        //Fetch App Asset Catalogs
        var appCARs: [AssetCatalog] = []
        var appCARFiles: [String] = []
        let apps = LSApplicationWorkspace().allInstalledApplications() as! [LSApplicationProxy]
        for app in apps {
            let carFile = app.bundleURL.path + "/Assets.car"
            if fm.fileExists(atPath: carFile) {
                appCARFiles.append(carFile)
            }
        }
        group.enter()
        for carFile in appCARFiles {
            DispatchQueue.global(qos: .userInteractive).async {
                let catalog = AssetCatalog(filePath: carFile)
                queue.async {
                    appCARs.append(catalog)
                    if appCARs.count == appCARFiles.count {
                        group.leave()
                    }
                }
            }
        }
        group.wait()
        //appCARs = appCARs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.AppCARs = appCARs
        
        
        //Fetch Control Center Asset Catalogs
        var ccCARs: [AssetCatalog] = []
        var ccCARFiles: [String] = []
        #if targetEnvironment(simulator)
        let ccPath = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/ControlCenter/Bundles/"
        #else
        let ccPath = "/System/Library/ControlCenter/Bundles/"
        #endif
        if let ccBundles = try? fm.contentsOfDirectory(atPath: ccPath) {
            for ccBundle in ccBundles {
                let carFile = "\(ccPath)/\(ccBundle)/Assets.car"
                if fm.fileExists(atPath: carFile) {
                    ccCARFiles.append(carFile)
                }
            }
        }
        group.enter()
        for carFile in ccCARFiles {
            DispatchQueue.global(qos: .userInteractive).async {
                let catalog = AssetCatalog(filePath: carFile)
                queue.async {
                    ccCARs.append(catalog)
                    if ccCARs.count == ccCARFiles.count {
                        group.leave()
                    }
                }
            }
        }
        group.wait()
        //ccCARs = ccCARs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.CCCARs = ccCARs
        
        
        //Fetch Framework and Core Services Asset Catalogs
        var frameworkCARs: [AssetCatalog] = []
        var frameworkCARFiles: [String] = []
        #if targetEnvironment(simulator)
        let frameworkPaths = [ "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreServices", "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks","/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks"]
        #else
        let frameworkPaths = [ "/System/Library/CoreServices", "/System/Library/Frameworks", "/System/Library/PrivateFrameworks"]
        #endif
        for path in frameworkPaths {
            if let frameworkBundles = try? fm.contentsOfDirectory(atPath: path) {
                for frameworkBundle in frameworkBundles {
                    if frameworkBundle != "CoreGlyphs.bundle" {
                        let carFile = "\(path)/\(frameworkBundle)/Assets.car"
                        if fm.fileExists(atPath: carFile) {
                            frameworkCARFiles.append(carFile)
                        }
                    }
                }
            }
        }
        group.enter()
        for carFile in frameworkCARFiles {
            DispatchQueue.global(qos: .userInteractive).async {
                let catalog = AssetCatalog(filePath: carFile)
                queue.async {
                    frameworkCARs.append(catalog)
                    if frameworkCARs.count == frameworkCARFiles.count {
                        group.leave()
                    }
                }
            }
        }
        group.wait()
        //frameworkCARs = frameworkCARs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.FrameworkCARs = frameworkCARs
        
        //setup doc folder
        #if !targetEnvironment(simulator)
        if !fm.fileExists(atPath: docURL.path) {
            try? fm.createDirectory(at: docURL, withIntermediateDirectories: true, attributes: nil)
        }
        #endif
        
    }
    
    private func macOSFetch() {
        
        let fm = FileManager.default
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "Aphrodite-ThreadSafeSerialQueue", qos: .userInteractive)

        //Fetch App Asset Catalogs
        var appCARs: [AssetCatalog] = []
        var appCARFiles: [String] = []
        if let appBundles = try? fm.contentsOfDirectory(atPath: "/Applications") {
            for app in appBundles {
                let carFile = "/Applications/\(app)/Contents/Resources/Assets.car"
                if fm.fileExists(atPath: carFile) {
                    appCARFiles.append(carFile)
                }
            }
        }
        group.enter()
        for carFile in appCARFiles {
            DispatchQueue.global(qos: .userInteractive).async {
                let catalog = AssetCatalog(filePath: carFile)
                queue.async {
                    appCARs.append(catalog)
                    if appCARs.count == appCARFiles.count {
                        group.leave()
                    }
                }
            }
        }
        group.wait()
        appCARs = appCARs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.AppCARs = appCARs
        
        //Fetch Framework and Core Services Asset Catalogs
        var frameworkCARs: [AssetCatalog] = []
        var frameworkCARFiles: [String] = []
        let frameworkPaths = [ "/System/Library/Frameworks", "/System/Library/PrivateFrameworks"]
        for path in frameworkPaths {
            if let frameworkBundles = try? fm.contentsOfDirectory(atPath: path) {
                for frameworkBundle in frameworkBundles {
                    let carFile = "\(path)/\(frameworkBundle)/Resources/Assets.car"
                    if fm.fileExists(atPath: carFile) {
                        frameworkCARFiles.append(carFile)
                    }
                }
            }
        }
        if let CoreServiceBundles = try? fm.contentsOfDirectory(atPath: "/System/Library/CoreServices") {
            for CoreServiceBundle in CoreServiceBundles {
                let carFile = "/System/Library/CoreServices/\(CoreServiceBundle)/Contents/Resources/Assets.car"
                if fm.fileExists(atPath: carFile) {
                    frameworkCARFiles.append(carFile)
                }
            }
        }
        group.enter()
        for carFile in frameworkCARFiles {
            DispatchQueue.global(qos: .userInteractive).async {
                let catalog = AssetCatalog(filePath: carFile)
                queue.async {
                    frameworkCARs.append(catalog)
                    if frameworkCARs.count == frameworkCARFiles.count {
                        group.leave()
                    }
                }
            }
        }
        group.wait()
        frameworkCARs = frameworkCARs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        self.FrameworkCARs = frameworkCARs
        
    }
    
    
    private func populateCarPathLookup() {
        let carIDs = AppCARs.map(\.carID) + CCCARs.map(\.carID) + FrameworkCARs.map(\.carID)
        let carPaths = AppCARs.map(\.path) + CCCARs.map(\.path) + FrameworkCARs.map(\.path)
        for (index, element) in carIDs.enumerated() {
            carPathLookup[element] = carPaths[index]
        }
    }
    
    
    private func encode() {
        let fm = FileManager.default
        DispatchQueue.global(qos: .utility).async {
            let folder = docURL.appendingPathComponent(".Data", isDirectory: true)
            if !fm.fileExists(atPath: folder.path) {
                try? fm.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            }
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.AppCARs) {
                try? encoded.write(to: folder.appendingPathComponent("Catalogs-App.json"))
            }
            if let encoded = try? encoder.encode(self.CCCARs) {
                try? encoded.write(to: folder.appendingPathComponent("Catalogs-CC.json"))
            }
            if let encoded = try? encoder.encode(self.FrameworkCARs) {
                try? encoded.write(to: folder.appendingPathComponent("Catalogs-Framework.json"))
            }
        }
    }
    
    
    private func decode(from url: URL) {
        let decoder = JSONDecoder()
        let queue = OperationQueue()
        queue.addOperation {
            if let appData = try? Data(contentsOf: url.appendingPathComponent("Catalogs-App.json")),
                let decoded = try? decoder.decode([AssetCatalog].self, from: appData) {
                self.AppCARs = decoded
            }
        }
        queue.addOperation {
            if let appData = try? Data(contentsOf: url.appendingPathComponent("Catalogs-CC.json")),
                let decoded = try? decoder.decode([AssetCatalog].self, from: appData) {
                self.CCCARs = decoded
            }
        }
        queue.addOperation {
            if let appData = try? Data(contentsOf: url.appendingPathComponent("Catalogs-Framework.json")),
                let decoded = try? decoder.decode([AssetCatalog].self, from: appData) {
                self.FrameworkCARs = decoded
            }
        }
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    private func shuffleCARArrays() {
        AppCARs.shuffle()
        CCCARs.shuffle()
        FrameworkCARs.shuffle()
    }
    
}
