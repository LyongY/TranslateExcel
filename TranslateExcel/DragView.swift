//
//  DragView.swift
//  APNs
//
//  Created by Raysharp666 on 2020/9/23.
//  Copyright © 2020 LyongY. All rights reserved.
//

import SwiftUI

struct DragView: View {
    var enableCondition: (String) -> Bool
    var dragInCallback: (String) -> Void
    var body: some View {
        DragViewRepresentable(parent: self)
    }
    
    init(enable: @escaping (String) -> Bool, dragIn: @escaping (String) -> Void) {
        enableCondition = enable
        dragInCallback = dragIn
    }
}

struct DragViewRepresentable: NSViewRepresentable {
    typealias NSViewType = DragView_AppKit
    
    var parent: DragView
    
    func makeNSView(context: Context) -> DragView_AppKit {
        let view = DragView_AppKit(parent: parent)
        view.registerForDraggedTypes([.fileContents, .fileURL])
        return view
    }
    
    func updateNSView(_ nsView: DragView_AppKit, context: Context) {
        
    }
    
    class DragView_AppKit: NSView {
        var parent: DragView
        init(parent: DragView) {
            self.parent = parent
            super.init(frame: .init(x: 0, y: 0, width: 100, height: 100))
            wantsLayer = true
            self.layer?.borderColor = NSColor.clear.cgColor
            self.layer?.borderWidth = 2
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var itemActive: Void {
            self.layer?.borderColor = NSColor.systemBlue.cgColor
        }
        var itemInactive: Void {
            self.layer?.borderColor = NSColor.clear.cgColor
        }
        
        override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            guard let path = sender.oneItemPath else {
                return .link
            }
            parent.enableCondition(path) ? itemActive : itemInactive
            return .link
        }
        
        override func draggingExited(_ sender: NSDraggingInfo?) {
            itemInactive
        }
        
        override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
            itemInactive
            guard let path = sender.oneItemPath else {
                return false
            }
            return parent.enableCondition(path)
        }
        
        override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard let path = sender.oneItemPath else {
                return false
            }
            if parent.enableCondition(path) {
                parent.dragInCallback(path)
                return true
            } else {
                return false
            }
        }
    }
}

extension NSDraggingInfo {
    var oneItemPath: String? {
        guard let urls = draggingPasteboard.readObjects(forClasses: [NSURL.self]) else {
            return nil
        }
        if urls.count != 1 {
            return nil
        }
        guard let url = urls.first as? NSURL else {
            return nil
        }
        return url.path
    }
}

struct DragView_Previews: PreviewProvider {
    static var previews: some View {
        DragView(enable: { (path) -> Bool in
            return path == "/Users/yly/Desktop/AuthKey_UK869F9YDU.p8"
        }) { (path) in
            
        }
    }
}
