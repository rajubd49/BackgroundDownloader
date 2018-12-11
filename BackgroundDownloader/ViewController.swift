//
//  ViewController.swift
//  BackgroundDownloader
//
//  Created by Raju on 11/20/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static let url = URL(string: "https://www.iso.org/files/live/sites/isoorg/files/archive/pdf/en/annual_report_2009.pdf") //Large Size PDF for test
//    static let url = URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf") //Small Size PDF for test
    
    private let shapeLayer = CAShapeLayer()
    private var downloadTask: URLSessionDownloadTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Downloader"
        addSubviewsToView()
        addCircularProgressView()
    }
    
    var progressPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = "0 %"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var progressSizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = "0.0 MB / 0.0 MB"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var downloadProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.setProgress(0.0, animated: false)
        progressView.trackTintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    lazy var foregroundDownloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Foreground Download", for: .normal)
        button.addTarget(self, action: #selector(foregroundDownload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var backgroundDownloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Background Download", for: .normal)
        button.addTarget(self, action: #selector(backgroundDownload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func foregroundDownload() {
        foregroundDownloadTask()
    }
    
    @objc func backgroundDownload() {
        backgroundDownloadTask()
    }
    
    fileprivate func addSubviewsToView() {
        
        self.view.addSubview(progressPercentLabel)
        self.view.addSubview(progressSizeLabel)
        self.view.addSubview(downloadProgressView)
        self.view.addSubview(foregroundDownloadButton)
        self.view.addSubview(backgroundDownloadButton)
        
        let percentLabelConstraints = [progressPercentLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                       progressPercentLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant:20)]
        NSLayoutConstraint.activate(percentLabelConstraints)
        
        let sizeLabelConstraints = [progressSizeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                    progressSizeLabel.topAnchor.constraint(equalTo: progressPercentLabel.bottomAnchor, constant:20)]
        NSLayoutConstraint.activate(sizeLabelConstraints)
        
        let progressViewConstraints = [downloadProgressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                       downloadProgressView.topAnchor.constraint(equalTo: progressSizeLabel.bottomAnchor, constant:20),
                                       downloadProgressView.widthAnchor.constraint(equalToConstant: 200)]
        NSLayoutConstraint.activate(progressViewConstraints)
        
        let foregroundConstraints = [foregroundDownloadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     foregroundDownloadButton.topAnchor.constraint(equalTo: downloadProgressView.bottomAnchor, constant:20)]
        NSLayoutConstraint.activate(foregroundConstraints)
        
        let backgroundConstraints = [backgroundDownloadButton.centerXAnchor.constraint(equalTo:self.view.centerXAnchor),
                                     backgroundDownloadButton.topAnchor.constraint(equalTo: foregroundDownloadButton.bottomAnchor, constant:20)]
        NSLayoutConstraint.activate(backgroundConstraints)
    }
    
    fileprivate func foregroundDownloadTask() {
        resetView()
        if let url = ViewController.url{
            let configuration = URLSessionConfiguration.default
            configuration.sessionSendsLaunchEvents = true
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
        }
    }
    
    fileprivate func backgroundDownloadTask() {
        resetView()
        if let url = ViewController.url {
            let configuration = URLSessionConfiguration.background(withIdentifier:UUID().uuidString)
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
        }
    }
    
    fileprivate func addCircularProgressView() {
        let center = CGPoint(x: view.center.x, y: view.center.y + 60)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: 150,
                                        startAngle: (-1)*CGFloat.pi/2,
                                        endAngle: (-1)*CGFloat.pi/2 + (2*CGFloat.pi),//FIXED
            clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0.0
        
        view.layer.addSublayer(shapeLayer)
        
        let dashedTrackLayer = CAShapeLayer()
        dashedTrackLayer.strokeColor = UIColor.lightGray.cgColor
        dashedTrackLayer.fillColor = nil
        dashedTrackLayer.lineDashPattern = [2, 4]
        dashedTrackLayer.lineJoin = CAShapeLayerLineJoin(rawValue: "round")
        dashedTrackLayer.lineWidth = 10.0
        dashedTrackLayer.path = shapeLayer.path
        view.layer.insertSublayer(dashedTrackLayer, below: shapeLayer)
    }
    
    fileprivate func startCircularProgress (progress: Float) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.strokeEnd = CGFloat(progress)
        shapeLayer.add(basicAnimation, forKey: "animateCircle")
    }
    
    private func convertFileSizeToMegabyte(size: Float) -> Float {
        return (size / 1024) / 1024
    }
    
    func resetView() {
        if downloadTask != nil {
            downloadTask.cancel()
        }
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(0.0, animated: false)
            self.progressPercentLabel.text = "0 %"
            self.progressSizeLabel.text = "0.0 MB / 0.0 MB"
        }
    }
    
}

extension ViewController:URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let url = ViewController.url, let documentsUrl = documentsUrl {
            let destinationFileUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: location, to: destinationFileUrl)
                print(destinationFileUrl.path)
            }
            catch let error as NSError {
                print("Failed moving directory: \(error)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Task completed: \(task), error: \(String(describing: error?.localizedDescription))")
        resetView()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            if totalBytesExpectedToWrite > 0 {
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                self.progressSizeLabel.text = String(format: "%.1f MB / %.1f MB", self.convertFileSizeToMegabyte(size: Float(totalBytesWritten)), self.convertFileSizeToMegabyte(size: Float(totalBytesExpectedToWrite)))
                self.progressPercentLabel.text = String(format: "%.2f %@", progress * 100,"%")
                self.downloadProgressView.setProgress(progress, animated: true)
                self.startCircularProgress(progress: progress)
                print("Progress \(downloadTask) \(progress)")
            }
        }
    }
    
}

