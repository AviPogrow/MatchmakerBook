//
//  ResumeScanVC.swift
//  NasiShadchanHelper
//
//  Created by Avi Pogrow on 2/21/26.
//  Copyright © 2026 user. All rights reserved.
//
import UIKit
import VisionKit
import Vision

protocol ResumeScanVCDelegate: AnyObject {
    func didScanAndParseResume(dict: [String: String])
}

final class ResumeScanVC: UIViewController, VNDocumentCameraViewControllerDelegate {

    weak var delegate: ResumeScanVCDelegate?

    private let parser = ResumeParser()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Scan Resume"
    }

    var didOpenScanner = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didOpenScanner else { return }
        didOpenScanner = true          // ✅ set BEFORE presenting
        presentDocumentScanner()
    }

    private func presentDocumentScanner() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }

    // MARK: - Scanner Delegate

    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        dismiss(animated: true)

        ocrAllPages(scan: scan) { [weak self] combinedText in
            guard let self else { return }

            let parsedDict = self.parser.parse(text: combinedText)
            self.presentReviewSheet(parsed: parsedDict, rawText: combinedText)
        }
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFailWithError error: Error) {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - OCR

    private func ocrAllPages(scan: VNDocumentCameraScan, completion: @escaping (String) -> Void) {
        let group = DispatchGroup()
        var results: [Int: String] = [:]

        for pageIndex in 0..<scan.pageCount {
            group.enter()
            let image = scan.imageOfPage(at: pageIndex)
            recognizeText(from: image) { text in
                results[pageIndex] = text
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let combined = (0..<scan.pageCount)
                .compactMap { results[$0] }
                .joined(separator: "\n")
            completion(combined)
        }
    }

    private func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let ciImage = CIImage(image: image) else { completion(""); return }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else { completion(""); return }
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            completion(lines.joined(separator: "\n"))
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do { try handler.perform([request]) }
            catch { completion("") }
        }
    }
    
    private func presentReviewSheet(parsed: [String: String], rawText: String) {
        let reviewVC = ParsedResumeReviewViewController(parsed: parsed, rawText: rawText) { [weak self] selectedDict in
            guard let self else { return }
            self.delegate?.didScanAndParseResume(dict: selectedDict)

            self.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }

        reviewVC.onCancel = { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }

        reviewVC.onRetake = { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true) {
                self.presentDocumentScanner()
            }
        }

        let nav = UINavigationController(rootViewController: reviewVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(nav, animated: true)
    }
   
}
