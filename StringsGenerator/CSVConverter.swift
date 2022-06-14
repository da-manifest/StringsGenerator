//
//  CSVConverter.swift
//  StringsGenerator
//
//  Created by Maksim Khozyashev on 10.06.2022.
//

import Foundation
import CSV

struct CSVConverter {

	static func makeHeadersAndBody(inputPath: String) -> (headers: [String], body: [[String]]) {
		guard let reader = makeCSVReader(inputPath: inputPath) else { return ([], []) }

		var body = [[String]]()
		for row in reader {
			body.append(row)
		}

		return (reader.headerRow ?? [], body)
	}

	private static func makeCSVReader(inputPath: String) -> CSVReader? {
		guard let stream = InputStream(fileAtPath: inputPath) else {
			ConsoleHelper.writeMessage("Input file not found", to: .error)
			return nil
		}

		do {
			let csv = try CSVReader(stream: stream, hasHeaderRow: true)
			return csv
		} catch {
			ConsoleHelper.writeMessage("Unexpected error: \(error).", to: .error)
			return nil
		}
	}
}
