import Foundation

extension String {
    typealias Byte = UInt8
    var hexToBytes: [Byte] {
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let end = index(after: start)
            defer { start = index(after: end) }
            return Byte(self[start...end], radix: 16)
        }
    }
    var hexToBinary: String {
        let notTrimmed = hexToBytes.map {
            let binary = String($0, radix: 2)
            return repeatElement("0", count: 8-binary.count) + binary
        }.joined()
        return notTrimmed.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }
}

func xorAll(linesToDecode codedLines: [String], indexOfCurrent index: Int, currentKey key: String) -> [String] {
    var result = [String]()

    let currentLineInBinary = codedLines[index].hexToBytes
    let keyInBinary:[UInt8] = Array(key.utf8)

    for codedLine in codedLines {
        let codedLineInBinary = codedLine.hexToBytes
        var temp_result = [UInt8]()
        
        for i in 0...(min(min(currentLineInBinary.count, codedLineInBinary.count), keyInBinary.count)-1) {
            let data = currentLineInBinary[i] ^ codedLineInBinary[i] ^ keyInBinary[i]
            temp_result.append(data)
        }
        result.append(String(decoding: temp_result, as: UTF8.self))
    }
    return result
}

let fileURL = Bundle.main.url(forResource: "Salsa20", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

var lines = content.components(separatedBy: "\n")

let key = "for who would bear the whips and scorns of time"

let result = xorAll(linesToDecode: lines, indexOfCurrent: 0, currentKey: key)

for (index, line) in result.enumerated() {
    print("\(index): \(line)")
}


