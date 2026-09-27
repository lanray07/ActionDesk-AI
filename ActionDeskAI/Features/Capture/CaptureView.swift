import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers
import VisionKit

struct CaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @State private var pastedText = ""
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isImportingFile = false
    @State private var scannerPresented = false
    private let intelligence: any DocumentIntelligenceService = PreviewDocumentIntelligenceService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) { Text("capture.heading").font(.largeTitle.bold()); Text("capture.subtitle").foregroundStyle(.secondary) }
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                        CaptureSource(title: "capture.camera", subtitle: "capture.camera.body", symbol: "doc.viewfinder") { scannerPresented = true }
                            .disabled(!VNDocumentCameraViewController.isSupported)
                        PhotosPicker(selection: $selectedPhoto, matching: .images) { CaptureSourceLabel(title: "capture.photo", subtitle: "capture.photo.body", symbol: "photo") }
                            .buttonStyle(.plain)
                        CaptureSource(title: "capture.pdf", subtitle: "capture.pdf.body", symbol: "doc.badge.plus") { isImportingFile = true }
                        CaptureSource(title: "capture.voice", subtitle: "capture.voice.body", symbol: "waveform") { pastedText = String(localized: "assistant.voice.preview") }
                    }
                    ADCard { VStack(alignment: .leading, spacing: 12) {
                        Label("capture.paste", systemImage: "doc.on.clipboard").font(.headline)
                        TextEditor(text: $pastedText).frame(minHeight: 130).padding(8).background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12)).accessibilityLabel("capture.paste.placeholder")
                        Button { analyze() } label: { if isAnalyzing { ProgressView().frame(maxWidth: .infinity) } else { Label("capture.analyze", systemImage: "sparkles").frame(maxWidth: .infinity) } }.buttonStyle(.borderedProminent).controlSize(.large).disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing)
                    } }
                    Label("capture.privacy", systemImage: "lock.shield").font(.footnote).foregroundStyle(.secondary)
                }.padding(16)
            }.background(ADColor.background).navigationTitle("capture.title").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("action.close") { dismiss() } } }
        }
        .sheet(isPresented: $scannerPresented) {
            DocumentScannerView(onComplete: { images in scannerPresented = false; extractScans(images) }, onCancel: { scannerPresented = false }).ignoresSafeArea()
        }
        .fileImporter(isPresented: $isImportingFile, allowedContentTypes: [.pdf, .image]) { result in importFile(result) }
        .onChange(of: selectedPhoto) { _, photo in guard let photo else { return }; Task { do { if let data = try await photo.loadTransferable(type: Data.self) { pastedText = try await OCRService.text(fromImageData: data) } } catch { errorMessage = error.localizedDescription } } }
        .alert("capture.error", isPresented: .init(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) { Button("action.ok", role: .cancel) {} } message: { Text(errorMessage ?? "") }
    }

    private func analyze() { isAnalyzing = true; Task { do { let item = try await intelligence.analyze(text: pastedText, outputLanguage: Locale.current.language); store.add(item); dismiss() } catch { errorMessage = error.localizedDescription }; isAnalyzing = false } }

    private func extractScans(_ images: [UIImage]) { isAnalyzing = true; Task { do { pastedText = try await OCRService.text(from: images) } catch { errorMessage = error.localizedDescription }; isAnalyzing = false } }

    private func importFile(_ result: Result<URL, Error>) {
        Task { do {
            let url = try result.get(); let scoped = url.startAccessingSecurityScopedResource(); defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            pastedText = url.pathExtension.lowercased() == "pdf" ? await OCRService.text(fromPDF: data) : try await OCRService.text(fromImageData: data)
        } catch { errorMessage = error.localizedDescription } }
    }
}

private struct CaptureSource: View {
    let title: LocalizedStringKey; let subtitle: LocalizedStringKey; let symbol: String; let action: () -> Void
    var body: some View { Button(action: action) { CaptureSourceLabel(title: title, subtitle: subtitle, symbol: symbol) }.buttonStyle(.plain) }
}

struct CaptureSourceLabel: View {
    let title: LocalizedStringKey; let subtitle: LocalizedStringKey; let symbol: String
    var body: some View { VStack(alignment: .leading, spacing: 9) { Image(systemName: symbol).font(.title).foregroundStyle(ADColor.accent); Text(title).font(.headline).foregroundStyle(.primary); Text(subtitle).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading); Spacer(minLength: 0) }.frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading).padding(15).background(ADColor.surface, in: RoundedRectangle(cornerRadius: 16)) }
}
