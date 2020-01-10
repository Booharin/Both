//
//  MainViewController.swift
//  Both
//
//  Created by Alexandr Booharin on 22/12/2019.
//  Copyright © 2019 Alexandr Booharin. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

protocol MainViewControllerProtocol {
    var containerView: UIView { get }
    var recordButton: RecordButton { get }
    var backCameraPreviewView: PreviewView { get }
    var frontCameraPreviewView: PreviewView { get }
}

final class MainViewController: UIViewController, MainViewControllerProtocol {
    
    var containerView = UIView()
    var backCameraPreviewView = PreviewView()
    var frontCameraPreviewView = PreviewView()
    var recordButton = RecordButton()
    var resumeButton = UIButton()
    var cameraUnavailableLabel: UILabel?
    private var backMaskView = UIView()
    private var frontMaskView = UIView()
    
    private var firstTime = true
    
    var viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.isUserInteractionEnabled = false
        addViews()
        viewModel.assosiateView(self)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(toPan))
        view.addGestureRecognizer(panGesture)
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            window.addGestureRecognizer(panGesture)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        viewModel.sessionQueue.async {
            switch self.viewModel.setupResult {
            case .success:
                    // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.viewModel.session.startRunning()
                self.viewModel.isSessionRunning = self.viewModel.session.isRunning
                    
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "\(Bundle.main.applicationName) doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: Bundle.main.applicationName, message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                                                    UIApplication.shared.open(settingsURL,
                                                                                              options: [:],
                                                                                              completionHandler: nil)
                                                                }
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: Bundle.main.applicationName, message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .multiCamNotSupported:
                DispatchQueue.main.async {
                    let alertMessage = "Alert message when multi cam is not supported"
                    let message = NSLocalizedString("Multi Cam Not Supported", comment: alertMessage)
                    let alertController = UIAlertController(title: Bundle.main.applicationName, message: message, preferredStyle: .alert)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.sessionQueue.async {
            if self.viewModel.setupResult == .success {
                self.viewModel.session.stopRunning()
                self.viewModel.isSessionRunning = self.viewModel.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    @objc private func didEnterBackground(notification: NSNotification) {
        // Free up resources.
        viewModel.dataOutputQueue.async {
            self.viewModel.renderingEnabled = false
            self.viewModel.videoMixer.reset()
            self.viewModel.currentPiPSampleBuffer = nil
        }
    }
    
    @objc func willEnterForground(notification: NSNotification) {
        viewModel.dataOutputQueue.async {
            self.viewModel.renderingEnabled = true
        }
    }
    
    // MARK: KVO and Notifications
    
    private var sessionRunningContext = 0
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    private func addObservers() {
        let keyValueObservation = viewModel.session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                self.recordButton.isUserInteractionEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        let systemPressureStateObservation = observe(\.self.viewModel.backCameraDeviceInput?.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue as? AVCaptureDevice.SystemPressureState else { return }
            self.viewModel.setRecommendedFrameRateRangeForPressureState(systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: viewModel.session)
        
        // A session can run only when the app is full screen. It will be interrupted in a multi-app layout.
        // Add observers to handle these session interruptions and inform the user.
        // See AVCaptureSessionWasInterruptedNotification for other interruption reasons.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: viewModel.session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: viewModel.session)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        /*
        Automatically try to restart the session running if media services were
        reset and the last start running succeeded. Otherwise, enable the user
        to try to resume the session running.
        */
        if error.code == .mediaServicesWereReset {
            viewModel.sessionQueue.async {
                if self.viewModel.isSessionRunning {
                    self.viewModel.session.startRunning()
                    self.viewModel.isSessionRunning = self.viewModel.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            resumeButton.isHidden = false
        }
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted (\(reason))")
            
            if reason == .videoDeviceInUseByAnotherClient {
                // Simply fade-in a button to enable the user to try to resume the session running.
                resumeButton.isHidden = false
                resumeButton.alpha = 0.0
                UIView.animate(withDuration: 0.25) {
                    self.resumeButton.alpha = 1.0
                }
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Simply fade-in a label to inform the user that the camera is unavailable.
                cameraUnavailableLabel?.isHidden = false
                cameraUnavailableLabel?.alpha = 0.0
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel?.alpha = 1.0
                }
            }
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        if !resumeButton.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.resumeButton.alpha = 0
            }, completion: { _ in
                self.resumeButton.isHidden = true
            })
        }
        if let label = cameraUnavailableLabel, !label.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.cameraUnavailableLabel?.alpha = 0
            }, completion: { _ in
                self.cameraUnavailableLabel?.isHidden = true
            })
        }
    }
    
    private func removeObservers() {
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        
        keyValueObservations.removeAll()
    }
    
    @objc func toPan(_ panGseture: UIPanGestureRecognizer) {
        let point = panGseture.location(in: self.view)
        
        let offset = -(UIScreen.main.bounds.height / 2 - point.y)
        backCameraPreviewView.snp.updateConstraints() {
            $0.height.equalTo(frontCameraPreviewView.snp.height).offset(offset)
        }
        
        setMasks()
    }
    
    private func addViews() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints() {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.addSubviews([
            backCameraPreviewView,
            frontCameraPreviewView,
            recordButton
        ])
        
        backCameraPreviewView.snp.makeConstraints() {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(frontCameraPreviewView.snp.height)
            $0.bottom.equalTo(frontCameraPreviewView.snp.top)
        }
        
        
        frontCameraPreviewView.snp.makeConstraints() {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(recordButton.snp.top).offset(-8)
        }
        
        recordButton.snp.makeConstraints() {
            $0.width.height.equalTo(70)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        view.layoutIfNeeded()
        setMasks()
    }
    
    private func setMasks() {
        // TODO: - test
        backCameraPreviewView.backgroundColor = .red
        frontCameraPreviewView.backgroundColor = .blue
        //let screenHeight = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        
        var backMaskHeight = backCameraPreviewView.frame.height
        var frontMaskHeight = frontCameraPreviewView.frame.height
        
        if firstTime {
            backMaskHeight -= 40
            frontMaskHeight -= 40
            firstTime = false
        }
        
        // back
        viewModel.backCameraVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        backMaskView = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: backCameraPreviewView.frame.width,
                                            height: backMaskHeight))
        backMaskView.layer.cornerRadius = backCameraPreviewView.frame.height < backCameraPreviewView.frame.width ?
            backMaskHeight / 2 : backCameraPreviewView.frame.width / 2
        backMaskView.backgroundColor = .brown
        backCameraPreviewView.mask = backMaskView
        
        // front
        viewModel.frontCameraVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        frontMaskView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: frontCameraPreviewView.frame.width,
                                             height: frontMaskHeight))
        frontMaskView.layer.cornerRadius = frontCameraPreviewView.frame.height < frontCameraPreviewView.frame.width ?
           frontMaskHeight / 2 : frontCameraPreviewView.frame.width / 2
        frontMaskView.backgroundColor = .brown
        frontCameraPreviewView.mask = frontMaskView
    }
}
