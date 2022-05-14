import Photos
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

let offsetRange = -10.0 ... 10.0 // acceptable offset range
let chartLengthRange = 0 ... 600 // acceptable chartLength range

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var Image: UIImage?
    @Binding var isPresented: Bool
    let configuration: PHPickerConfiguration
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false // Set isPresented to false because picking has finished.
            let itemProviders = results.map(\.itemProvider)
            for item in itemProviders {
                if item.canLoadObject(ofClass: UIImage.self) {
                    item.loadObject(ofClass: UIImage.self) { image, _ in
                        DispatchQueue.main.async { [self] in
                            if let image = image as? UIImage {
                                self.parent.Image = image
                            }
                        }
                    }
                }
            }
        }
    }
}

struct URLExportDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.zip]
    var data: DataStructure?
    init(data: DataStructure) {
        self.data = data
    }

    init(configuration _: ReadConfiguration) throws {}
    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: try data!.exportZip())
    }
}

struct ChartSettings: View {
    @EnvironmentObject private var data: DataStructure
    @State private var newPreferTick = 3.0
    @State private var image: Image?
    @State private var zipURL: URL?
    @State private var showingImagePicker = false
    @State private var showingExporter = false
    @State private var showingImporter = false
    var body: some View {
        List {
            Section(header: Text("File Operation:")) {
                Button("Import Music") {
                    showingImporter = true
                }

                Button("Import Photo") {
                    showingImagePicker = true
                }
                Button("Export '.zip' file") {
                    do {
                        // save the data first
                        try _ = data.saveCache()
                        try self.zipURL = data.exportZip()
                        showingExporter = true
                    } catch {}
                }
                Button("Import '.zip' file") {
                    showingImporter = true
                }
                Button("Save to local storage") {
                    do {
                        try _ = data.saveCache()
                    } catch {}
                }
                Button("Reload from local storage") {
                    // let alertController = UIAlertController(title: "Confirm", message: "This would override everything", preferredStyle: .actionSheet)
                    // let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    // let confirmAction = UIAlertAction(title: "Confirm,", style: .default, handler: { _ in
                    //     do {
                    //         try _ = data.loadCache()
                    //     } catch {}
                    // })
                    // alertController.addAction(cancelAction)
                    // alertController.addAction(confirmAction)	
                    // alertController.present(.self, animated: true, completion: nil)
                }.foregroundColor(Color.red)
            }.textCase(nil)
            Section(header: Text("Information:")) {
                HStack {
                    Text("Music Name:")
                    TextField("Music", text: $data.musicName).foregroundColor(Color.blue)
                }
                HStack {
                    Text("Music Author:")
                    TextField("Author", text: $data.authorName).foregroundColor(Color.blue)
                }
                HStack {
                    Text("Chart Level:")
                    TextField("Level", text: $data.chartLevel).foregroundColor(Color.orange)
                }
                HStack {
                    Text("Chart Author:")
                    TextField("Chart Author", text: $data.chartAuthorName).foregroundColor(Color.orange)
                }
                Menu("Copyright: \(String(describing: data.copyright).uppercased())") {
                    Button("[Full copyright]", action: {
                        data.copyright = .full
                    })
                    Button("[Limited copyright]", action: {
                        data.copyright = .limited
                    })
                    Button("[No copyright]", action: {
                        data.copyright = .none
                    })
                }
            }.textCase(nil)
            Section(header: Text("Variables:")) {
                Stepper(value: $data.offsetSecond, in: offsetRange, step: 0.005) {
                    Text("Offset: \(NSString(format: "%.3f", data.offsetSecond))s")
                }

                Toggle(isOn: $data.bpmChangeAccrodingToTime) {
                    Text("Allow BPM changes")
                }
                if !data.bpmChangeAccrodingToTime {
                    Stepper(value: $data.bpm) {
                        Text("BPM: \(data.bpm)")
                    }
                } else {
                    // TODO: Add support for changing BPM, gonna be a pain in the ass
                    Button("Edit BPM Props") {}
                }
                Stepper(value: $data.chartLengthSecond, in: chartLengthRange) {
                    Text("Length: \(data.chartLengthSecond)s")
                }
            }.textCase(nil)

            Section(header: Text("Preferred Ticks")) {
                ForEach($data.highlightedTicks, id: \.value) { $tick in
                    ColorPicker("Tick: 1/" + String(tick.value), selection: $tick.color)

                }.onDelete(perform: { offset in
                    data.highlightedTicks.remove(atOffsets: offset)
                })

                VStack {
                    Stepper(value: $newPreferTick, in: 0 ... Double(data.tickPerBeat), step: 1) {
                        Text("NewTick: 1/\(Int(newPreferTick))")
                    }
                    Button("Add tick", action: {
                        if data.highlightedTicks.filter({ $0.value == Int(newPreferTick) }).count != 0 || data.tickPerBeat % Int(newPreferTick) != 0 {
                            return
                        } else {
                            // add a random color to the new preferTick
                            data.highlightedTicks.append(ColoredInt(value: Int(newPreferTick), color: Color(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1))))
                        }

                    })
                }
            }.onChange(of: data.highlightedTicks) { _ in }
                .textCase(nil)

            Section(header: Text("Do not change these:")) {
                Stepper(value: $data.tickPerBeat,
                        onEditingChanged: { _ in }) {
                    Text("Tick: \(data.tickPerBeat)")
                }
            }
        }.sheet(isPresented: $showingImagePicker) {
            let configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            ImagePicker(Image: $data.imageFile, isPresented: $showingImagePicker, configuration: configuration)
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.zip, .mp3], allowsMultipleSelection: false) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                if selectedFile.pathExtension == "zip" {
                    if selectedFile.startAccessingSecurityScopedResource() {
                        let fm = FileManager.default
                        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
                        if let url = urls.first {
                            let fileURL = url.appendingPathComponent("import.zip")
                            if fm.fileExists(atPath: fileURL.path) {
                                try fm.removeItem(at: fileURL)
                            }
                            try fm.copyItem(at: selectedFile, to: fileURL)
                            try _ = self.data.importZip()
                        }
                    } else {
                        // Handle denied access
                    }
                } else {
                    if selectedFile.startAccessingSecurityScopedResource() {
                        let fm = FileManager.default
                        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
                        if let url = urls.first {
                            let dirPath = url.appendingPathComponent("tmp")
                            if !fm.fileExists(atPath: dirPath.path) {
                                try fm.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
                            }
                            let fileURL = dirPath.appendingPathComponent("tmp.mp3")
                            if fm.fileExists(atPath: fileURL.path) {
                                try fm.removeItem(at: fileURL)
                            }
                            try fm.copyItem(at: selectedFile, to: fileURL)
                            data.audioFileURL = fileURL
                        }
                    } else {}
                }

            } catch {
                // Handle failure.
            }
        }
        .fileExporter(isPresented: $showingExporter, document: URLExportDocument(data: data), contentType: .zip, onCompletion: { _ in })
    }
}
