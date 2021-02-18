//
//  FlatList.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/17/21.
//

import SwiftUI

// MARK: - FlatList

struct FlatList<Data : RandomAccessCollection, RowContent : View> : View where Data.Element : Identifiable {
    var data: Data
    var rowContent: (Data.Element) -> RowContent

    init(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.rowContent = rowContent
    }

    var body: some View {
        ScrollView {
            ForEach(data, content: rowContent)
                .padding()
        }
    }
}

// MARK: - FlatListSection

struct FlatListSection<Parent: View, Content : View> : View {
    var header: Parent
    var content: () -> Content

    init(header: Parent, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.content = content
    }

    var body: some View {
        VStack {
            HStack {
                header
                Spacer()
            }
        }

        VStack {
            content()
        }
    }
}

// MARK: - FlatInnerList

struct FlatInnerList<Data : RandomAccessCollection, RowContent : View> : View where Data.Element : Identifiable {
    var data: Data
    var rowContent: (Data.Element) -> RowContent

    init(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.rowContent = rowContent
    }

    var body: some View {
        ForEach(data, content: rowContent)
    }
}
