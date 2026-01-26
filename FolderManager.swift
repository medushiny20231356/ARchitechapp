//
//  FolderManager.swift
//  ARCHITECH
//
//  Created by S.MEDUSHINY on 2026-01-26.
//

//
//  FolderManager.swift
//  ARchitechTesting
//
//  Created by S.MEDUSHINY on 2026-01-26.
//

import Foundation

class CaptureFolderManager {
    let rootDir: URL
    let imagesDir: URL
    let snapshotsDir: URL
    let modelDir: URL
    
    // initializer
    init?() {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let scanId = ISO8601DateFormatter().string(from: Date())
        self.rootDir = docs.appendingPathComponent("Scans/\(scanId)")
        self.imagesDir = rootDir.appendingPathComponent("Images")
        self.snapshotsDir = rootDir.appendingPathComponent("Snapshots")
        self.modelDir = rootDir.appendingPathComponent("Model")
        
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: snapshotsDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)
    }
}
