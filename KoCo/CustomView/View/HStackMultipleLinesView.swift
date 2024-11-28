//
//  HStackMultipleLinesView.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import SwiftUI

// 다중 선택할 수 있는 멀티 라인 HStack
struct HStackMultipleLinesMultipleSelectButtonView: View {
    var elements : [LocalizedStringKey]
    var clickable : Bool = true
    var forgroundColor : Color = Assets.Colors.skyblue
    var buttonHeight : CGFloat = 35
    //    var backgroundColor : Color = .clear
    //    var haveBorderLine : Bool = true
    
    @Binding var clickedIndexs : [Int]
    @State private var totalHeight : CGFloat = CGFloat.zero
    
    var body: some View {
        GeometryReader{ geo in
            elementsView(in: geo, tags: elements)
        }
            .frame(height: totalHeight)
        
    }
    
    private func elementsView(in geo: GeometryProxy, tags : [LocalizedStringKey]) -> some View {
        var width = CGFloat.zero //현재 줄에서 각 버튼의 시작 위치(수평 위치) = ⭐️⭐️현재 줄에서 지금까지 쌓인 요소들의 width 다음에 그려져야한다⭐️⭐️ -> 각 버튼은 앞선 버튼 너비만큼 오른쪽으로 이동하여 배치
        var height = CGFloat.zero //각 버튼의 시작 위치(수직 위치)
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags.enumerated()), id: \.offset) { (offset: Int, tag: LocalizedStringKey) in
                Button {
                    if(clickedIndexs.contains(offset)){
                        let deleteIndex = clickedIndexs.firstIndex{$0 == offset}
                        clickedIndexs.remove(at: deleteIndex!)
                    }else{
                        clickedIndexs.append(offset)
                    }
                    
                    print("🌸🌸🌸🌸clickedIndexs", clickedIndexs)
                } label : {
                    Text(tag)
                        .font(.system(size: 13))
                        .padding()
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 8)
                        .foregroundColor(clickedIndexs.contains(offset) ? .white : forgroundColor)
                        .frame(height: buttonHeight)
                        .background(clickedIndexs.contains(offset) ? forgroundColor : .white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke( forgroundColor, lineWidth: clickedIndexs.contains(offset) ? 0 : 1)
                        )
                        .padding([.horizontal, .vertical], 8)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 2)
                        .alignmentGuide(.leading, computeValue: { dimensions in
                            //width 값을 기반으로 각 버튼의 수평 위치를 결정합니다. 각 버튼은 앞선 버튼 너비만큼 오른쪽으로 이동하여 배치
                            
                            //alignmentGuide(.leading) -> HorizontalAlignment : leading으로부터의 정렬
                            //dimensions(ViewDimensions) : 뷰의 사이즈와 정렬 가이드에 대한 정보가 담겨있다
                            // 메소드의 클로저에서 수행된 계산에 따라 horizontal 정렬을 기준으로 수정된 뷰
                            
                            // 1️⃣ 다음줄로 넘어갈지의 여부 파악
                            if (abs(width - dimensions.width) > geo.size.width){
                                //geometry width를 넘었을때 => 다음line으로 넘어갈 수 있도록
                                width = 0
                                height -= dimensions.height
                            }
                            
                            // 2️⃣ result(어느 위치에서부터 그려줄지) 결정
                            let result = width
                            
                            // 3️⃣ -> 다음 요소(뷰)를 를 어디서 시작해줄지 결정
                            if offset == tags.count-1 {
                                //last item => width를 0으로 초기화
                                width = 0
                                
                            } else {
                                //이 뷰 의 크기(dimensions.width) 만큼 width를 줄여준다
                                width -= dimensions.width
                            }

                            return result
                        })
                        .alignmentGuide(.top, computeValue: { _ in 
                            //height를 사용하여 수직 위치를 결정하고
                            //새로운 줄이 시작될 때 height를 업데이트하여 새로운 줄의 높이를 반영(이건 alignmentGuide(.leading) 여기서 결정해줌)
                            
                            //alignmentGuide(.top) -> VerticalAlignment : top으로부터의 정렬
                            
                            // 1️⃣ result(어느 위치에서부터 그려줄지) 결정
                            let result = height
                            if offset == tags.count-1 {
                                // last item => height를 0으로 초기화
                                height = 0
                            }
                            return result
                        })

                }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
