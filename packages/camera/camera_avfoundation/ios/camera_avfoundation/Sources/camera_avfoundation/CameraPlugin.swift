// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import ObjectiveC

//typealias CaptureNamedDeviceFactory = (String) -> NSObject & FLTCaptureDevice

public final class CameraPlugin: NSObject, FlutterPlugin, FCPCameraApi {
  let registry: FlutterTextureRegistry
  let messenger: FlutterBinaryMessenger
  let globalEventAPI: FCPCameraGlobalEventApi
  let permissionManager: FLTCameraPermissionManager
  let deviceDiscoverer: FLTCameraDeviceDiscovering
  let captureDeviceFactory: CaptureNamedDeviceFactory
  let captureSessionFactory: CaptureSessionFactory
  let captureDeviceInputFactory: FLTCaptureDeviceInputFactory

  /// All FLTCam's state access and capture session related operations should be on run on this queue.
  let captureSessionQueue: DispatchQueue

  /// An internal camera object that manages camera's state and performs camera operations.
  public var camera: FLTCam?

  convenience init(registry: FlutterTextureRegistry, messenger: FlutterBinaryMessenger) {
    self.init(
      registry: registry, messenger: messenger,
      globalEventAPI: FCPCameraGlobalEventApi(binaryMessenger: messenger),
      permissionManager: FLTCameraPermissionManager(
        permissionService: FLTDefaultPermissionService()),
      deviceDiscoverer: FLTDefaultCameraDeviceDiscoverer(),
      captureDeviceFactory: { name in
        return FLTDefaultCaptureDevice(device: AVCaptureDevice(uniqueID: name)!)  // FIXME
      },
      captureSessionFactory: {
        return FLTDefaultCaptureSession(captureSession: AVCaptureSession())
      }, captureDeviceInputFactory: FLTDefaultCaptureDeviceInputFactory())
  }

  public init(
    registry: FlutterTextureRegistry,
    messenger: FlutterBinaryMessenger,
    globalEventAPI: FCPCameraGlobalEventApi,
    permissionManager: FLTCameraPermissionManager,
    deviceDiscoverer: FLTCameraDeviceDiscovering,
    captureDeviceFactory: @escaping CaptureNamedDeviceFactory,
    captureSessionFactory: @escaping CaptureSessionFactory,
    captureDeviceInputFactory: FLTCaptureDeviceInputFactory
  ) {
    self.registry = registry
    self.messenger = messenger
    self.globalEventAPI = globalEventAPI
    self.permissionManager = permissionManager
    self.deviceDiscoverer = deviceDiscoverer
    self.captureDeviceFactory = captureDeviceFactory
    self.captureSessionFactory = captureSessionFactory
    self.captureDeviceInputFactory = captureDeviceInputFactory

    self.captureSessionQueue = DispatchQueue(label: "io.flutter.camera.captureSessionQueue")

    super.init()

    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)

    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(
      forName: UIDevice.orientationDidChangeNotification,
      object: UIDevice.current,
      queue: .main,
      using: orientationChanged
    )
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CameraPlugin(registry: registrar.textures(), messenger: registrar.messenger())

    //    CameraApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance) FIXME
  }

  func orientationChanged(_ notification: Notification) {
    guard let device = notification.object as? UIDevice else { return }
    let orientation = device.orientation

    // Do not change when the device is flat (face up or face down)
    if orientation == .faceUp || orientation == .faceDown {
      return
    }

    // Use a weak reference to self to avoid retain cycles
    weak var weakSelf = self
    self.captureSessionQueue.async { [weak weakSelf] in
      guard let strongSelf = weakSelf else { return }

      // `setDeviceOrientation` must be called on the capture session queue
      strongSelf.camera?.setDeviceOrientation(orientation)

      // `sendDeviceOrientation` can be called on any queue
      strongSelf.sendDeviceOrientation(orientation)
    }
  }

  func sendDeviceOrientation(_ orientation: UIDeviceOrientation) {
    weak var weakSelf = self
    DispatchQueue.main.async { [weak weakSelf] in
      guard let strongSelf = weakSelf else { return }

      strongSelf.globalEventAPI.deviceOrientationChangedOrientation(
        getPigeonDeviceOrientationForOrientation(orientation),
        completion: { _ in
          // Ignore errors; this is essentially a broadcast stream, and
          // it's fine if the other end doesn't receive the message
          // (e.g., if it doesn't currently have a listener set up).
        })
    }
  }

  public func availableCameras(
    completion: @escaping ([FCPPlatformCameraDescription]?, FlutterError?) -> Void
  ) {

  }

  public func createCamera(
    withName cameraName: String, settings: FCPPlatformMediaSettings,
    completion: @escaping (NSNumber?, FlutterError?) -> Void
  ) {

  }

  public func initializeCamera(
    _ cameraId: Int, withImageFormat imageFormat: FCPPlatformImageFormatGroup,
    completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func startImageStream(completion: @escaping (FlutterError?) -> Void) {

  }

  public func stopImageStream(completion: @escaping (FlutterError?) -> Void) {

  }

  public func receivedImageStreamData(completion: @escaping (FlutterError?) -> Void) {

  }

  public func disposeCamera(_ cameraId: Int, completion: @escaping (FlutterError?) -> Void) {

  }

  public func lockCapture(
    _ orientation: FCPPlatformDeviceOrientation, completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.lockCapture(orientation)
      completion(nil)
    }
  }

  public func unlockCaptureOrientation(completion: @escaping (FlutterError?) -> Void) {

  }

  public func takePicture(completion: @escaping (String?, FlutterError?) -> Void) {

  }

  public func prepareForVideoRecording(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setUpCaptureSessionForAudioIfNeeded()
      completion(nil)
    }
  }

  public func startVideoRecording(
    withStreaming enableStream: Bool, completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func stopVideoRecording(completion: @escaping (String?, FlutterError?) -> Void) {

  }

  public func pauseVideoRecording(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.pauseVideoRecording()
      completion(nil)
    }
  }

  public func resumeVideoRecording(completion: @escaping (FlutterError?) -> Void) {

  }

  public func setFlashMode(
    _ mode: FCPPlatformFlashMode, completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func setExposureMode(
    _ mode: FCPPlatformExposureMode, completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func setExposurePoint(
    _ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func getMinimumExposureOffset(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {

  }

  public func getMaximumExposureOffset(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {

  }

  public func setExposureOffset(_ offset: Double, completion: @escaping (FlutterError?) -> Void) {

  }

  public func setFocusMode(
    _ mode: FCPPlatformFocusMode, completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func setFocus(_ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void) {

  }

  public func getMinimumZoomLevel(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {

  }

  public func getMaximumZoomLevel(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {

  }

  public func setZoomLevel(_ zoom: Double, completion: @escaping (FlutterError?) -> Void) {

  }

  public func pausePreview(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.pausePreview()
      completion(nil)
    }
  }

  public func resumePreview(completion: @escaping (FlutterError?) -> Void) {

  }

  public func updateDescriptionWhileRecordingCameraName(
    _ cameraName: String, completion: @escaping (FlutterError?) -> Void
  ) {

  }

  public func setImageFileFormat(
    _ format: FCPPlatformImageFileFormat, completion: @escaping (FlutterError?) -> Void
  ) {

  }

}
