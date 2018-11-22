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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Downloader"
        addSubviewsToView()
    }
    
    var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = "0"
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
        
        self.view.addSubview(foregroundDownloadButton)
        self.view.addSubview(backgroundDownloadButton)
        self.view.addSubview(downloadProgressView)
        self.view.addSubview(progressLabel)
        
        let backgroundConstraints = [backgroundDownloadButton.centerXAnchor.constraint(equalTo:self.view.centerXAnchor),
                                     backgroundDownloadButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)]
        NSLayoutConstraint.activate(backgroundConstraints)
        
        let foregroundConstraints = [foregroundDownloadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     foregroundDownloadButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant:-50)]
        NSLayoutConstraint.activate(foregroundConstraints)
        
        let progressViewConstraints = [downloadProgressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     downloadProgressView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant:-100),
                                     downloadProgressView.leadingAnchor.constraint(equalTo: backgroundDownloadButton.leadingAnchor),
                                     downloadProgressView.trailingAnchor.constraint(equalTo: backgroundDownloadButton.trailingAnchor)]
        NSLayoutConstraint.activate(progressViewConstraints)
        
        let labelConstraints = [progressLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     progressLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant:-150)]
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    fileprivate func foregroundDownloadTask() {
        downloadProgressView.setProgress(0.0, animated: false)
        progressLabel.text = "0"
        if let url = ViewController.url{
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            let downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
        }
    }
    
    fileprivate func backgroundDownloadTask() {
        downloadProgressView.setProgress(0.0, animated: false)
        progressLabel.text = "0"
        if let url = ViewController.url {
            let configuration = URLSessionConfiguration.background(withIdentifier:UUID().uuidString)
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            let downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
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
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            if totalBytesExpectedToWrite > 0 {
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                self.downloadProgressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
                self.progressLabel.text = String(format: "%.2f %%", progress * 100)
                print("Progress \(downloadTask) \(progress)")
            }
        }
    }
    
}

