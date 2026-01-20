import Foundation

public final class MediaController {
    private var listeningProcess: Process?
    private var dataBuffer = Data()
    private var isPlaying = false
    private var seekTimer: Timer?

    public var onTrackInfoReceived: ((TrackInfo?, [String: Any]?) -> Void)?
    public var onPlaybackStateReceived: ((Int?) -> Void)?
    public var onDecodingError: ((Error, Data) -> Void)?
    public var onListenerTerminated: (() -> Void)?

    public var bundleIdentifiers: [String] {
        didSet {
            if listeningProcess != nil {
                stopListening()
                startListening()
            }
        }
    }

    public init(bundleIdentifiers: [String] = []) {
        self.bundleIdentifiers = bundleIdentifiers
    }

    private var perlScriptPath: String? {
        guard let path = Bundle.module.path(forResource: "run", ofType: "pl") else {
            assertionFailure("run.pl script not found in bundle resources.")
            return nil
        }
        return path
    }

    private var libraryPath: String? {
        let bundle = Bundle(for: MediaController.self)
        guard let path = bundle.executablePath else {
            assertionFailure("Could not locate the executable path for the MediaRemoteAdapter framework.")
            return nil
        }
        return path
    }

    @discardableResult
    private func runPerlCommand(arguments: [String]) -> (output: String?, error: String?, terminationStatus: Int32) {
        guard let scriptPath = perlScriptPath else {
            return (nil, "Perl script not found.", -1)
        }
        guard let libraryPath = libraryPath else {
            return (nil, "Dynamic library path not found.", -1)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        process.arguments = [scriptPath, libraryPath] + arguments

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        // Use buffers and readabilityHandler to avoid pipe deadlock.
        // The deadlock occurs when:
        // 1. Parent calls waitUntilExit() before reading pipe
        // 2. Child writes to stdout, filling the pipe buffer (typically 64KB)
        // 3. Child blocks on write, cannot exit
        // 4. Parent waits forever for child to exit
        var outputData = Data()
        var errorData = Data()
        let outputLock = NSLock()
        let errorLock = NSLock()

        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                outputLock.lock()
                outputData.append(data)
                outputLock.unlock()
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                errorLock.lock()
                errorData.append(data)
                errorLock.unlock()
            }
        }

        do {
            try process.run()
            process.waitUntilExit()

            // Stop the readability handlers
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil

            // Read any remaining data
            outputLock.lock()
            let remainingOutput = outputPipe.fileHandleForReading.readDataToEndOfFile()
            outputData.append(remainingOutput)
            outputLock.unlock()

            errorLock.lock()
            let remainingError = errorPipe.fileHandleForReading.readDataToEndOfFile()
            errorData.append(remainingError)
            errorLock.unlock()

            let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            return (output, errorOutput, process.terminationStatus)
        } catch {
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            return (nil, error.localizedDescription, -1)
        }
    }

    public func startListening() {
        guard listeningProcess == nil else {
            print("Listener process is already running.")
            return
        }

        guard let scriptPath = perlScriptPath else {
            return
        }
        guard let libraryPath = libraryPath else {
            return
        }

        listeningProcess = Process()
        listeningProcess?.executableURL = URL(fileURLWithPath: "/usr/bin/perl")

        var arguments = [scriptPath]
        if !bundleIdentifiers.isEmpty {
            arguments.append("--id")
            arguments.append(bundleIdentifiers.joined(separator: "|"))
        }
        arguments.append(contentsOf: [libraryPath, "loop"])
        listeningProcess?.arguments = arguments

        let outputPipe = Pipe()
        listeningProcess?.standardOutput = outputPipe

        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            guard let self = self else { return }

            let incomingData = fileHandle.availableData
            if incomingData.isEmpty {
                // This can happen when the process terminates.
                return
            }

            self.dataBuffer.append(incomingData)

            // Process all complete lines in the buffer.
            while let range = self.dataBuffer.firstRange(of: "\n".data(using: .utf8)!) {
                let lineData = self.dataBuffer.subdata(in: 0 ..< range.lowerBound)

                // Remove the line and the newline character from the buffer.
                self.dataBuffer.removeSubrange(0 ..< range.upperBound)

                if !lineData.isEmpty {
                    processIncomingLine(lineData)
                }
            }
        }

        listeningProcess?.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                self?.listeningProcess = nil
                self?.onListenerTerminated?()
            }
        }

        do {
            try listeningProcess?.run()
        } catch {
            print("Failed to start listening process: \(error)")
            listeningProcess = nil
        }
    }

    private func processIncomingLine(_ lineData: Data, userInfo: [String: Any]? = nil) {
        guard !lineData.isEmpty else { return }
        do {
            let rawInfo = try JSONSerialization.jsonObject(with: lineData) as? [AnyHashable: Any] ?? [:]
            let notificationName = rawInfo["notificationName"] as? String ?? ""
            let payload = rawInfo["payload"] as? [AnyHashable: Any] ?? [:]

            if notificationName == "kMRMediaRemoteNowPlayingInfoDidChangeNotification" {
                let trackInfo: TrackInfo?
                if payload.isEmpty {
                    trackInfo = nil
                } else {
                    trackInfo = try JSONDecoder().decode(TrackInfo.self, from: JSONSerialization.data(withJSONObject: payload))
                }
                DispatchQueue.main.async {
                    self.onTrackInfoReceived?(trackInfo, userInfo)
                }
            } else if notificationName == "kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification" {
                let playbackState = payload["playbackState"] as? Int
                DispatchQueue.main.async {
                    self.onPlaybackStateReceived?(playbackState)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.onDecodingError?(error, lineData)
            }
        }
    }

    public func stopListening() {
        listeningProcess?.terminate()
        listeningProcess = nil
    }

    public func play() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["play"])
        }
    }

    public func pause() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["pause"])
        }
    }

    public func togglePlayPause() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["toggle_play_pause"])
        }
    }

    public func nextTrack() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["next_track"])
        }
    }

    public func previousTrack() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["previous_track"])
        }
    }

    public func stop() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["stop"])
        }
    }

    public func updatePlayerState(userInfo: [String: Any] = [:]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.runPerlCommand(arguments: ["update_player_state"])
            if let output = result.output, !output.isEmpty {
                let lines = output.components(separatedBy: .newlines)
                for line in lines {
                    if let data = line.data(using: .utf8) {
                        self.processIncomingLine(data, userInfo: userInfo)
                    }
                }
            }
        }
    }

    public func setTime(seconds: Double) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPerlCommand(arguments: ["set_time", String(seconds)])
        }
    }
}
