//
//  EmailView.swift
//  Buttonup
//
//  Created by Russell Blickhan on 1/14/22.
//

import Markdown
import RealmSwift
import SwiftUI

struct EmailView: View {
    @ObservedRealmObject var email: Email

    private var markdown: AttributedString {
        var markdownosaur = Markdownosaur()
        return AttributedString(markdownosaur.attributedString(from: Markdown.Document(parsing: email.body)))
    }

    var body: some View {
        ScrollView {
            Text(markdown)
        }
    }
}
