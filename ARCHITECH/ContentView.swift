//
//  ContentView.swift
//  ARchitechTesting
//
//  Created by S.MEDUSHINY on 2026-01-26.
//  Nikitha added this comment to see whether everyone could commit on this document.

import SwiftUI
import RealityKit
import QuickLook

struct ScannerView: View {
    @State var session = ObjectCaptureSession()
    @State private var folderManager = CaptureFolderManager()
    @State private var isProcessing = false
    
    // Preview variables
    @State private var modelURL: URL?
    @State private var showPreview = false
    
    var body: some View {
        ZStack {
            if !isProcessing {
                ObjectCaptureView(session: session)
                VStack {
                    Spacer()
                    
                    // The button only appears after a successful scan
                    if let _ = modelURL {
                        Button("View 3D Model") {
                            showPreview = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding()
                    }
                    
                    controlButtons
                }
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Reconstructing 3D Model...")
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: $showPreview) {
            if let url = modelURL {
                ARQuickLookView(modelURL: url)
            }
        }
        .onAppear { startNewSession() }
        .onChange(of: session.state) {
            if case .completed = session.state {
                isProcessing = true
                Task { await runReconstruction() }
            }
        }
    }
    
    private var controlButtons: some View {
        Group {
            if case .ready = session.state {
                Button("Start Detecting") { session.startDetecting() }
            } else if case .detecting = session.state {
                Button("Start Capturing") { session.startCapturing() }
            } else if session.userCompletedScanPass {
                Button("Finish Scan") { session.finish() }
            }
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 30)
    }
    
    func startNewSession() {
        guard let folders = folderManager else { return }
        var config = ObjectCaptureSession.Configuration()
        config.checkpointDirectory = folders.snapshotsDir
        session.start(imagesDirectory: folders.imagesDir, configuration: config)
    }
}
//Reconstruction Extension
extension ScannerView {
    func runReconstruction() async {
        guard let folders = folderManager else { return }
        let outputURL = folders.modelDir.appendingPathComponent("model.usdz")
        
        do {
            let photoSession = try PhotogrammetrySession(input: folders.imagesDir)
            let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: .reduced)
            
            try photoSession.process(requests: [request])
            
            for try await output in photoSession.outputs {
                switch output {
                case .processingComplete:
                    // The UI connected to the main thread
                    await MainActor.run {
                        self.modelURL = outputURL
                        self.isProcessing = false
                    }
                    print("Success! Model saved at \(outputURL)")
                case .requestProgress(_, let fraction):
                    print("Progress: \(Int(fraction * 100))%")
                default: break
                }
            }
        } catch {
            print("Reconstruction Error: \(error)")
            await MainActor.run { isProcessing = false }
        }
    }
}


//AR Quick Look View
struct ARQuickLookView: UIViewControllerRepresentable {
    let modelURL: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ vc: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: ARQuickLookView
        init(parent: ARQuickLookView) { self.parent = parent }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            parent.modelURL as QLPreviewItem
        }
    }
}

