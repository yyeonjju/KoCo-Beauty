//
//  BottomSheetView.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import SwiftUI



fileprivate enum Constants {
    static let radius: CGFloat = 40
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
//    static let minHeightRatio: CGFloat = 0.3
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let showIndicator : Bool
    let title : String?
    let isIgnoredSafeArea : Bool
    let allowDragGeture : Bool
    let content: Content
    
    
    @GestureState private var translation: CGFloat = 0
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
            )
            .onTapGesture {
                self.isOpen.toggle()
            }
    }
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, showIndicator : Bool = true, title : String? = nil, isIgnoredSafeArea : Bool = true, allowDragGeture : Bool = true, minHeightRatio : CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight * minHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
        self.showIndicator = showIndicator
        self.title = title
        self.isIgnoredSafeArea = isIgnoredSafeArea
        self.allowDragGeture = allowDragGeture
        self._isOpen = isOpen
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if(showIndicator){
                    self.indicator.padding()
                }
                if(title != nil){
                    HStack{
                        Text(title ?? "")
                            .font(.system(size:20, weight:.bold))
                            .padding(20)
                        Spacer()
                    }

                }
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.white)
            .cornerRadius(Constants.radius, corners: .topLeft)
            .cornerRadius(Constants.radius, corners: .topRight)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * Constants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
                ,including: self.allowDragGeture ? .all : .subviews //subviews : Enable all gestures in the subview hierarchy but disable the added gesture.
            )
        }
        .edgesIgnoringSafeArea(isIgnoredSafeArea ? .all : .horizontal)
    }
    
}

extension View {
    //shape
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
           clipShape( RoundedCorner(radius: radius, corners: corners) )
       }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

