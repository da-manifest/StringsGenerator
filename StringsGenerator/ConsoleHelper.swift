//
//  ConsoleHelper.swift
//  StringsGenerator
//
//  Created by Jayakumar Vivek on 04/12/2020.
//

import Foundation


enum OutputType {
	case error
	case warning
	case standard
	case success
}

struct ConsoleHelper {
    static func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
		case .error:
			fputs("\u{001B}[1;31m❌Error: \(message)\n\u{001B}[0;0m", stderr)
		case .warning:
			print("\u{001B}[0;33m❕\(message)\u{001B}[0;0m")
        case .standard:
            print("\(message)")
		case .success:
			print("\u{001B}[0;32m✅\(message)\u{001B}[0;0m")
		}
    }
}
