// ChartSettings.swift
// Author: TianKai Ma
// Last Reviewed: 2022-05-22 20:39
import PhotosUI
import SwiftUI
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
    @State private var showAlert = false
    @State private var showingImagePicker = false
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()

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
                        try _ = data.saveCache()
                        try self.zipURL = data.exportZip()
                        showingExporter = true
                    } catch {
                        print(error)
                    }
                }
                Button("Import '.zip' file") {
                    showingImporter = true
                }
                Button("Save to local storage") {
                    do {
                        try _ = data.saveCache()
                    } catch {
                        print(error)
                    }
                }
                Button("Reload from local storage") {
                    showAlert = true
                }.alert(isPresented: $showAlert) {
                    Alert(title: Text("Confirm reload?"), message: Text("This would override all current settings"), primaryButton: .default(Text("cancel")), secondaryButton: .destructive(Text("Reload"), action: {
                        do {
                            try _ = data.loadCache()
                        } catch {
                            print(error)
                        }
                    }))
                }
                .foregroundColor(Color.red)
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
                Menu("Copyright: \(String(describing: data.copyright).capitalizingFirstLetter())") {
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
            Section(header: Text("Settings:")) {
                Stepper(value: $data.offsetSecond, in: offsetRange, step: 0.005) {
                    HStack {
                        Text("Offset:")
                        TextField("[Double]/s", value: $data.offsetSecond, formatter: numberFormatter)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                    }
                }

                Toggle(isOn: $data.bpmChangeAccrodingToTime) {
                    Text("Allow BPM changes")
                        .foregroundColor(.red)
                }
                if !data.bpmChangeAccrodingToTime {
                    Stepper(value: $data.bpm) {
                        HStack {
                            Text("BPM:")
                            TextField("[Double]", value: $data.bpm, formatter: numberFormatter)
                                .keyboardType(.numberPad)
                                .submitLabel(.done)
                        }
                    }
                } else {
                    // TODO: Add support for changing BPM, gonna be a pain in the ass
                    Button("Edit BPM Props") {}
                }
                Stepper(value: $data.chartLengthSecond, in: chartLengthRange) {
                    HStack {
                        Text("Chart Length:")
                        TextField("[Int]/s", value: $data.chartLengthSecond, formatter: numberFormatter)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                    }
                }
            }.textCase(nil)

            Section(header: Text("HighLight Tick:")) {
                ForEach($data.highlightedTicks, id: \.value) { $tick in
                    ColorPicker("Beat: 1/" + String(tick.value), selection: $tick.color)

                }.onDelete(perform: { offset in
                    data.highlightedTicks.remove(atOffsets: offset)
                })

                VStack {
                    Stepper(value: $newPreferTick, in: 0 ... Double(data.tickPerBeat), step: 1) {
                        Text("New Beat: 1/\(Int(newPreferTick))")
                    }
                    Button("Add", action: {
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

            Section(header: Text("Advanced Settings:")) {
                Stepper(value: $data.tickPerBeat, onEditingChanged: { _ in }) {
                    Text("Tick: \(data.tickPerBeat)")
                }.foregroundColor(.red)
                Toggle(isOn: $data.fastHold) {
                    Text("Fast Hold")
                        .foregroundColor(.red)
                }
                Stepper(value: $data.maxAcceptableNotes, onEditingChanged: { _ in }) {
                    HStack {
                        Text("Note Division:")
                        TextField("[Int]", value: $data.maxAcceptableNotes, formatter: numberFormatter)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                    }
                }
                Stepper(value: $data.defaultHoldTimeTick, onEditingChanged: { _ in }) {
                    HStack {
                        Text("Default Hold Time:")
                        TextField("[Int]/T", value: $data.defaultHoldTimeTick, formatter: numberFormatter)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                    }
                }
            }.textCase(nil)
        }.sheet(isPresented: $showingImagePicker) {
            let configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            ImagePicker(Image: $data.imageFile, isPresented: $showingImagePicker, configuration: configuration)
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.zip, .mp3], allowsMultipleSelection: false) { result in
            // Hint here: the file importer doesn't actually care which button user hit, whether it's importing a .zip file or a .mp3 file, they're all handled here.
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                if selectedFile.startAccessingSecurityScopedResource() {
                    let fm = FileManager.default
                    let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
                    if let url = urls.first {
                        // TODO: I would probably argue that this part of logic should move to definition.swift...
                        if selectedFile.pathExtension == "zip" {
                            let fileURL = url.appendingPathComponent("import.zip")
                            if fm.fileExists(atPath: fileURL.path) {
                                try fm.removeItem(at: fileURL)
                            }
                            try fm.copyItem(at: selectedFile, to: fileURL)
                            try _ = self.data.importZip()
                        } else {
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
                    }
                } else {
                    print("[Err]: Denied access to user-seleted file at ChartSettings.swift")
                }
            } catch {
                print(error)
            }
        }
        .fileExporter(isPresented: $showingExporter, document: URLExportDocument(data: data), contentType: .zip, onCompletion: { _ in })
    }
}
