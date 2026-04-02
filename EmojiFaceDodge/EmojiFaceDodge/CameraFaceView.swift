//
//  CameraFaceView.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import AVFoundation
import SwiftUI

struct CameraFaceView: UIViewRepresentable {
    @Binding var faceRect: CGRect?

    func makeCoordinator() -> Coordinator {
        Coordinator(faceRect: $faceRect)
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.videoGravity = .resizeAspectFill
        context.coordinator.attachPreviewLayer(view.previewLayer)
        context.coordinator.start()
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.frame = uiView.bounds
        context.coordinator.attachPreviewLayer(uiView.previewLayer)
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: Coordinator) {
        coordinator.stop()
    }

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let faceRectBinding: Binding<CGRect?>

        private let captureSession = AVCaptureSession()
        private let metadataOutput = AVCaptureMetadataOutput()
        private weak var previewLayer: AVCaptureVideoPreviewLayer?

        private var isConfigured: Bool = false
        private var isRunning: Bool = false

        init(faceRect: Binding<CGRect?>) {
            self.faceRectBinding = faceRect
        }

        private func applyFrontCameraMirroring(to connection: AVCaptureConnection) {
            guard connection.isVideoMirroringSupported else { return }
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }

        func attachPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
            previewLayer = layer
            if layer.session !== captureSession {
                layer.session = captureSession
            }

            if let connection = layer.connection {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                applyFrontCameraMirroring(to: connection)
            }
        }

        func start() {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                configureIfNeeded()
                startRunningIfNeeded()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        if granted {
                            self.configureIfNeeded()
                            self.startRunningIfNeeded()
                        } else {
                            self.faceRectBinding.wrappedValue = nil
                        }
                    }
                }
            default:
                faceRectBinding.wrappedValue = nil
            }
        }

        func stop() {
            guard isRunning else { return }
            captureSession.stopRunning()
            isRunning = false
            faceRectBinding.wrappedValue = nil
        }

        private func configureIfNeeded() {
            guard !isConfigured else { return }
            isConfigured = true

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .high

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                let input = try? AVCaptureDeviceInput(device: device),
                captureSession.canAddInput(input)
            else {
                captureSession.commitConfiguration()
                return
            }
            captureSession.addInput(input)

            guard captureSession.canAddOutput(metadataOutput) else {
                captureSession.commitConfiguration()
                return
            }
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            if metadataOutput.availableMetadataObjectTypes.contains(.face) {
                metadataOutput.metadataObjectTypes = [.face]
            }

            if let connection = metadataOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                applyFrontCameraMirroring(to: connection)
            }

            captureSession.commitConfiguration()
        }

        private func startRunningIfNeeded() {
            guard !isRunning else { return }
            captureSession.startRunning()
            isRunning = true
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard let previewLayer else { return }

            guard
                let faceObject = metadataObjects.compactMap({ $0 as? AVMetadataFaceObject }).first,
                let transformedObject = previewLayer.transformedMetadataObject(for: faceObject)
            else {
                faceRectBinding.wrappedValue = nil
                return
            }

            var rect = transformedObject.bounds
            rect = rect.insetBy(dx: -18, dy: -18)
            faceRectBinding.wrappedValue = rect
        }
    }
}

#Preview {
    CameraFaceView(faceRect: .constant(nil))
        .ignoresSafeArea()
}
