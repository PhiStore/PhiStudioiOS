import Photos
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var Image: UIImage?
    let configuration: PHPickerConfiguration
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Use a Coordinator to act as your PHPickerViewControllerDelegate
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

struct ChartSettings: View {
    @EnvironmentObject private var data: DataStructure

    let offsetRange = -10.0 ... 10.0 // acceptable offset range
    let chartLengthRange = 0 ... 600 // acceptable chartLength range
    @State private var newPreferTick = 3.0
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var showingMusicPicker = false
    @State private var zipURL: URL?
    @State private var showingExporter = false
    @State private var showingImporter = false
    var body: some View {
        List {
            Section(header: Text("File Operation:")) {
                Button("Import Music...") {
//                    showingMusicPicker = true
                    showingImporter = true
                }

                Button("Import Photo...") {
                    showingImagePicker = true
                }
                Button("Export '.zip' file...") {
                    do {
                        try _ = data.saveCache()
                        try self.zipURL = data.exportZip()

                    } catch {}
                    showingExporter = true
                }
                Button("Import '.zip' file...") {
                    showingImporter = true
                }
                Button("Save to local storage") {
                    do {
                        try _ = data.saveCache()
                    } catch {}
                }.foregroundColor(Color.red)
                Button("Reload from local storage") {
                    do {
                        try _ = data.loadCache()
                    } catch {}
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
                Menu("Copyright Info") {
                    Button("[Full copyright]", action: {})
                    Button("[Limited copyright]", action: {})
                    Button("[No copyright]", action: {})
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
                    // work to be done here. - give a editor on time-changing BPM
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
            ImagePicker(Image: $data.imageFile, configuration: configuration, isPresented: $showingImagePicker)
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
                print(error)
            }
        }
        .fileExporter(isPresented: $showingExporter, document: URLExportDocument(data: data), contentType: .zip, onCompletion: { _ in })
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

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        let tmpData = DataStructure()
        ChartSettings().environmentObject(tmpData)
    }
}
