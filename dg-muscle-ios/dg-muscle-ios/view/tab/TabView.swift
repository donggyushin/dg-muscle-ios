//
//  TabView.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 2023/09/24.
//

import SwiftUI

struct TabView: View {
    @State var selectedTab: TabItemsView.Tab = .diary
    let settingViewDependency: SettingViewDependency
    
    var body: some View {
        VStack {
            switch selectedTab {
            case .diary:
                VStack {
                    Text("temp")
                    Spacer()
                }
                
            case .setting:
                SettingView(dependency: settingViewDependency)
            }
            TabItemsView(selectedTab: $selectedTab)
        }
        
    }
}
