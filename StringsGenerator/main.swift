//
//  main.swift
//  StringsGenerator
//
//  Created by Jayakumar, Vivek on 04/12/2020.
//

import Foundation


let packageURL = Bundle.main.bundleURL.deletingLastPathComponent()
let csvPath = packageURL.path + "/Scripts/LocalizeCSV"
let localizationPath = packageURL.path + "/Sources/Resources/Localization"

// Search for .csv files
ConsoleHelper.writeMessage("Looking for CSV files")
let enumerator = FileManager.default.enumerator(atPath: csvPath)
if enumerator == nil {
	ConsoleHelper.writeMessage("CSV directory not found at path: " + csvPath, to: .error)
	exit(0)
}
let filePaths = enumerator?.allObjects as! [String]
let csvFilePaths = filePaths.filter { $0.hasSuffix(".csv") }
if csvFilePaths.isEmpty {
	ConsoleHelper.writeMessage("No CSV files found at path: " + csvPath, to: .error)
	exit(0)
}
for csvFilePath in csvFilePaths {
	ConsoleHelper.writeMessage("File found: " + csvFilePath)
}
ConsoleHelper.writeMessage("\(csvFilePaths.count) files found")

// Process files
ConsoleHelper.writeMessage("Processing files")
var results = [Bool]()
for csvFilePath in csvFilePaths {
	let inputPath = csvPath + "/" + csvFilePath
	ConsoleHelper.writeMessage("Processing file: " + inputPath)
	results.append(StringsHelper(inputPath: inputPath,
								 outputPath: localizationPath).generateLocalizables())
}

// Print results
if results.contains(false) {
	let totalCount = csvFilePaths.count
	let errorCount = results.filter { !$0 }.count
	ConsoleHelper.writeMessage("\(errorCount) out of \(totalCount) files processed with error",
							   to: .error)
	exit(0)
} else {
	ConsoleHelper.writeMessage("All CSV files processed successfully 🎉🎉🎉",
							   to: .success)
	exit(0)
}

