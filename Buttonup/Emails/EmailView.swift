//
//  EmailView.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/14/22.
//

import Kingfisher
import Markdown
import RealmSwift
import SwiftUI

struct EmailView: View {
    private let emailRepo = EmailRepository()

    @ObservedRealmObject var email: Email

    private enum TextOrImageBlock: Identifiable {
        case text(NSAttributedString, index: Int)
        case image(source: String?, title: String?, index: Int)

        var id: Int {
            switch self {
            case let .text(_, index), let .image(_, _, index): return index
            }
        }
    }

    private var markdown: some View {
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: Markdown.Document(parsing: email.body))

        var blocks = [TextOrImageBlock]()
        var index = 0
        attributedString.enumerateAttribute(
            NSAttributedString.Key.imgSource,
            in: NSRange(0 ..< attributedString.length),
            using: { value, range, _ in
                if let value = value as? String {
                    // TODO: do something with the title
                    blocks.append(.image(source: value, title: nil, index: index))
                } else {
                    blocks.append(.text(attributedString.attributedSubstring(from: range), index: index))
                }
                index += 1
            })

        return VStack {
            ForEach(blocks) { block in
                switch block {
                case let .image(source, _, _): KFImage(URL(string: source ?? "")).resizable()
                    .aspectRatio(contentMode: .fit)
                case let .text(string, _): Text(AttributedString(string))
                }
            }
        }
    }

    var body: some View {
        List {
            markdown
        }
        .refreshable {
            do {
                try await emailRepo.fetch(email.id)
            } catch {
                print(error)
            }
        }.navigationTitle(email.subject)
    }
}
