//
//  ConsoleIO.swift
//  SwiftScript
//
//  Created by Jayakumar Vivek on 30/10/2020.
//

import Foundation


private enum Constants {
	static let languagePrefix = "IOS_"
	static let csvFilePrefix = "Localize - "
	static let localizableSuffix = ".strings"
	static let directorySuffix = ".lproj"
}

struct StringsHelper {

    private let inputPath: String
    private let outputPath: String
	private var csvHeaders: [String]
	private var csvBody: [[String]]
    
    init(inputPath: String,
         outputPath: String) {
        self.inputPath = inputPath
        self.outputPath = outputPath
		let (headers, body) = CSVConverter.makeHeadersAndBody(inputPath: inputPath)
		self.csvHeaders = headers
		self.csvBody = body
    }

    func generateLocalizables() -> Bool {
		let languages = getLanguages()

		guard !languages.isEmpty,
			  !csvHeaders.isEmpty,
			  !csvBody.isEmpty
		else { return false }

		var results = [Bool]()
        for language in languages {
			results.append(generateLocalizable(langCode: language))
        }

		return !results.contains(false)
    }
}

private extension StringsHelper {
	private func getLanguages() -> [String] {
		var languages = csvHeaders
		languages = skipIdRow(languages)

		guard !languages.isEmpty else {
			ConsoleHelper.writeMessage("No languages found in file", to: .error)
			return []
		}

		ConsoleHelper.writeMessage("\(languages.count) languages found in file")

		return languages
	}

	private func generateLocalizable(langCode: String) -> Bool {
		let headers = csvHeaders
		guard let index = headers.firstIndex(of: langCode) else {
			ConsoleHelper.writeMessage("Language \(langCode) not found", to: .error)
			return false
		}

		var generatedString = makeSignature()
		var section = ""

		let csvBody = removeRowsWithEmptyKeys(csvBody)
		for row in csvBody {
			let sectionFromKey = row[0].components(separatedBy: ".")[0]

			if sectionFromKey != section {
				generatedString += "\n// \(sectionFromKey)\n"
			}
			section = sectionFromKey
			let key = row[0].replacingOccurrences(of: "\"", with: "")
			let value = row[index].replacingOccurrences(of: "\"", with: "")
			generatedString += "\"\(key)\" = \"\(value)\";\n"
		}

		return writeToFile(writeText: generatedString, langCode: langCode)
	}

	private func skipIdRow(_ languages: [String]) -> [String] {
		Array(languages.dropFirst())
	}

	private func makeSignature() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm E, d MMM y"
		return "// AUTO-GENERATED at " + formatter.string(from: Date()) + ".\n\n"
	}

	private func removeRowsWithEmptyKeys(_ body: [[String]]) -> [[String]] {
		body.filter { row in
			let key = row[0]
			return !key.isEmpty
		}
	}
}

// MARK: - Write to file
private extension StringsHelper {
	private func writeToFile(writeText: String,
							 langCode: String) -> Bool {
		let fileManager = FileManager.default
		let directory = URL(fileURLWithPath: outputPath)
		let langugePath = directory
			.appendingPathComponent("\(makeDirectoryName(langCode: langCode))")
		let filePath = langugePath.appendingPathComponent("\(makeFileName())")
		do {
			if !fileManager.fileExists(atPath: langugePath.path) {
				var message = "Directory not found: \(langugePath.path)\n"
				message += "Attempting to create the directory."
				ConsoleHelper.writeMessage(message, to: .warning)
				try fileManager.createDirectory(atPath: langugePath.path,
												withIntermediateDirectories: true,
												attributes: nil)
				ConsoleHelper.writeMessage("Created the directory at: \(langugePath.path)")
			}
			try writeText.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
			ConsoleHelper.writeMessage("File generated at: \(filePath.path)", to: .success)
		} catch {
			ConsoleHelper.writeMessage("Failed to write: \n\(error)", to: .error)
			return false
		}
		return true
	}

	private func makeFileName() -> String {
		var result = inputPath
		result = URL(fileURLWithPath: result).deletingPathExtension().lastPathComponent
		result = result.replacingOccurrences(of: Constants.csvFilePrefix, with: "")
		result += Constants.localizableSuffix
		return result
	}

	private func makeDirectoryName(langCode: String) -> String {
		langCode
			.replacingOccurrences(of: Constants.languagePrefix, with: "")
			.lowercased() + Constants.directorySuffix
	}
}
