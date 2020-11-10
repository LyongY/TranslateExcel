//
//  ProgressBar.swift
//  TranslateExcel
//
//  Created by Raysharp666 on 2020/11/2.
//  Copyright © 2020 LyongY. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var maxValue: Int
    @Binding var minValue: Int
    @Binding var currentValue: Int
    var body: some View {
        ProgressBarRepresentable(parent: self)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(maxValue: .constant(5), minValue: .constant(0), currentValue: .constant(3))
    }
}

fileprivate struct ProgressBarRepresentable: NSViewRepresentable {
    var parent: ProgressBar
    
    func makeNSView(context: Context) -> NSProgressIndicator {
        let view = NSProgressIndicator()
        view.style = .bar
        view.isIndeterminate = false
        view.controlSize = .regular
        view.maxValue = Double(self.parent.maxValue)
        view.minValue = Double(self.parent.minValue)
        view.doubleValue = Double(self.parent.currentValue)
        view.startAnimation(nil)
        return view
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        nsView.minValue = Double(self.parent.minValue)
        nsView.maxValue = Double(self.parent.maxValue)
        nsView.doubleValue = Double(self.parent.currentValue)
    }
    
    typealias NSViewType = NSProgressIndicator
}
