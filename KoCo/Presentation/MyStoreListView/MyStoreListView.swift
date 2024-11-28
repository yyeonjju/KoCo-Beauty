//
//  MyStoreListView.swift
//  KoCo
//
//  Created by 하연주 on 11/17/24.
//

import SwiftUI

struct MyStoreListView: View {
    @StateObject private var vm = MyStoreListViewModel(myStoreRepository: MyStoreRepository())
    @Environment(\.dismiss) var dismiss
    
    var mode : MyStoreMode
    @Binding var selectedMyStore : MyStoreInfo?
    
    var body: some View {
        ScrollView{
            if vm.output.myStoreList.isEmpty {
                VStack {
                    Text(" 매장이 없습니다")
                }
                .padding(.top, 50)
            } else {
                LazyVStack {
                    ForEach(vm.output.myStoreList, id: \.id) { myStore in
                        let categories = myStore.categoryName.components(separatedBy: ">")
                        let categoryText = categories.count>1 ? categories[categories.count-1] : "-"
                        
                        Button {
                            selectedMyStore = myStore
                            dismiss()
                        }label : {
                            StoreInfoHeaderView(
                                placeName: myStore.KakaoPaceName,
                                categoryText: categoryText,
                                addressName: myStore.addressName
                            )
                            .padding()
                        }
                        
                        Divider()
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear{
            vm.action(.getMyStoreList(mode: mode))
        }
        
    }
}

//#Preview {
//    NavigationView{
//        MyStoreListView(mode: .flaged)
//            .navigationTitle(Text("하하"))
//    }
//    
//}



