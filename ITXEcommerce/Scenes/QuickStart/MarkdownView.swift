//
//  MarkdownView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 31/3/26.
//

import SwiftUI

// MARK: - MarkdownView

struct MarkdownView: View {
    let content: String

    private var blocks: [MarkdownBlock] { MarkdownParser.parse(content) }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                MarkdownBlockView(block: block)
            }
        }
    }
}

// MARK: - Block model

enum MarkdownBlock {
    case heading(level: Int, text: String)
    case paragraph(text: String)
    case divider
    case codeBlock(language: String?, lines: [String])
    case table(headers: [String], rows: [[String]])
    case bulletItem(indent: Int, text: String)
    case blank
}

// MARK: - Parser

private enum MarkdownParser {
    static func parse(_ content: String) -> [MarkdownBlock] {
        let lines = content.components(separatedBy: .newlines)
        var blocks: [MarkdownBlock] = []
        var index = 0

        while index < lines.count {
            let line = lines[index]

            // Code fence
            if line.hasPrefix("```") {
                let lang = line.dropFirst(3).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                index += 1
                while index < lines.count && !lines[index].hasPrefix("```") {
                    codeLines.append(lines[index])
                    index += 1
                }
                blocks.append(.codeBlock(language: lang.isEmpty ? nil : lang, lines: codeLines))
                index += 1
                continue
            }

            // Heading
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let text = String(line.dropFirst(level)).trimmingCharacters(in: .whitespaces)
                blocks.append(.heading(level: min(level, 6), text: text))
                index += 1
                continue
            }

            // Divider
            if line == "---" || line == "***" || line == "___" {
                blocks.append(.divider)
                index += 1
                continue
            }

            // Table – detect by |…| pattern on first column row
            if line.contains("|") {
                var tableLines: [String] = []
                while index < lines.count && lines[index].contains("|") {
                    tableLines.append(lines[index])
                    index += 1
                }
                if tableLines.count >= 2 {
                    let headers = parseTableRow(tableLines[0])
                    // Skip separator row (---|---) if present
                    let dataStart = tableLines.count > 1 && tableLines[1].contains("-") ? 2 : 1
                    let rows = tableLines.dropFirst(dataStart).map { parseTableRow($0) }
                    blocks.append(.table(headers: headers, rows: Array(rows)))
                } else {
                    // Not a real table, treat as paragraph
                    for tl in tableLines {
                        blocks.append(.paragraph(text: tl))
                    }
                }
                continue
            }

            // Bullet list
            if let bulletMatch = bulletPrefix(line) {
                blocks.append(.bulletItem(indent: bulletMatch.indent, text: bulletMatch.text))
                index += 1
                continue
            }

            // Blank line
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                blocks.append(.blank)
                index += 1
                continue
            }

            // Paragraph
            blocks.append(.paragraph(text: line))
            index += 1
        }

        return blocks
    }

    private static func parseTableRow(_ row: String) -> [String] {
        row.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private struct BulletMatch { let indent: Int; let text: String }
    private static func bulletPrefix(_ line: String) -> BulletMatch? {
        var indent = 0
        var rest = line[line.startIndex...]
        while rest.first == " " { rest = rest.dropFirst(); indent += 1 }
        if rest.hasPrefix("- ") || rest.hasPrefix("* ") || rest.hasPrefix("+ ") {
            return BulletMatch(indent: indent / 2, text: String(rest.dropFirst(2)))
        }
        return nil
    }
}

// MARK: - Block renderer

private struct MarkdownBlockView: View {
    let block: MarkdownBlock

    var body: some View {
        switch block {
        case .heading(let level, let text):
            HeadingView(level: level, text: text)
        case .paragraph(let text):
            InlineMarkdownText(text)
                .padding(.bottom, 4)
        case .divider:
            Divider()
                .padding(.vertical, 8)
        case .codeBlock(_, let lines):
            CodeBlockView(lines: lines)
        case .table(let headers, let rows):
            MarkdownTableView(headers: headers, rows: rows)
        case .bulletItem(let indent, let text):
            BulletItemView(indent: indent, text: text)
        case .blank:
            Color.clear.frame(height: 8)
        }
    }
}

// MARK: - Sub-views

private struct HeadingView: View {
    let level: Int
    let text: String

    var body: some View {
        Group {
            switch level {
            case 1: Text(text).font(.largeTitle).fontWeight(.bold)
            case 2: Text(text).font(.title).fontWeight(.bold)
            case 3: Text(text).font(.title2).fontWeight(.semibold)
            case 4: Text(text).font(.title3).fontWeight(.semibold)
            default: Text(text).font(.headline)
            }
        }
        .padding(.top, level <= 2 ? 16 : 10)
        .padding(.bottom, 4)
    }
}

private struct CodeBlockView: View {
    let lines: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(lines.joined(separator: "\n"))
                .font(.system(.caption, design: .monospaced))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .padding(.vertical, 4)
    }
}

private struct MarkdownTableView: View {
    let headers: [String]
    let rows: [[String]]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                ForEach(headers, id: \.self) { header in
                    Text(header)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
            }
            .background(.secondary.opacity(0.15))

            Divider()

            // Data rows
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                        Text(cell)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                    }
                }
                .background(index.isMultiple(of: 2) ? Color.clear : .secondary.opacity(0.05))
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3), lineWidth: 1))
        .padding(.vertical, 6)
    }
}

private struct BulletItemView: View {
    let indent: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.callout)
                .foregroundStyle(.secondary)
            InlineMarkdownText(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, CGFloat(indent) * 16)
        .padding(.vertical, 1)
    }
}

// MARK: - Inline markdown text

private struct InlineMarkdownText: View {
    let raw: String

    init(_ raw: String) { self.raw = raw }

    var body: some View {
        if let attributed = try? AttributedString(
            markdown: raw,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            Text(attributed).font(.callout)
        } else {
            Text(raw).font(.callout)
        }
    }
}

// MARK: - Previews

#Preview {
    ScrollView {
        MarkdownView(content: """
        # Heading 1
        ## Heading 2

        A paragraph with **bold**, *italic*, and `inline code`.

        ---

        | Name | Value |
        |------|-------|
        | Foo  | 42    |
        | Bar  | 99    |

        - First item
        - Second item
          - Nested item

        ```swift
        let x = 42
        print(x)
        ```
        """)
        .padding()
    }
}
