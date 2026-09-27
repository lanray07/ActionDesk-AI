import Foundation
import PDFKit
import UIKit
import Vision

enum OCRService {
    static func text(fromPDF data: Data) async -> String {
        PDFDocument(data: data)?.string ?? ""
    }

    static func text(fromImageData data: Data) async throws -> String {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else { return "" }
        return try await text(from: [cgImage])
    }

    static func text(from images: [UIImage]) async throws -> String {
        try await text(from: images.compactMap(\.cgImage))
    }

    private static func text(from images: [CGImage]) async throws -> String {
        var pages: [String] = []
        for image in images {
            let page = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                let request = VNRecognizeTextRequest { request, error in
                    if let error { continuation.resume(throwing: error); return }
                    let text = (request.results as? [VNRecognizedTextObservation])?.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n") ?? ""
                    continuation.resume(returning: text)
                }
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                DispatchQueue.global(qos: .userInitiated).async {
                    do { try VNImageRequestHandler(cgImage: image).perform([request]) }
                    catch { continuation.resume(throwing: error) }
                }
            }
            pages.append(page)
        }
        return pages.joined(separator: "\n\n")
    }
}

