//
//  HeatMapColumnView.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/15/24.
//

import SwiftUI

struct HeatMapColumnView: View {
    
    @State var data: WorkoutHeatMapViewModel.Data
    @State var maxVolume: Double
    
    private let size: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 3) {
            ForEach(data.volumes) { volume in
                if volume.value == 0 {
                    RoundedRectangle(cornerRadius: 2).fill(.gray).opacity(0.2)
                        .frame(width: size, height: size)
                } else {
                    RoundedRectangle(cornerRadius: 2).fill(.green).opacity(volume.value / maxVolume)
                        .frame(width: size, height: size)
                }
            }
        }
    }
}

#Preview {
    
    let data: WorkoutHeatMapViewModel.Data = .init(week: "202416", volumes: [4, 0, 4, 8, 10].map({ .init(value: $0) }))
    
    return HeatMapColumnView(data: data, maxVolume: 10)
        .preferredColorScheme(.dark)
}