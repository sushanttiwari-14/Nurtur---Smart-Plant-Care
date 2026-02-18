//
//  mainscreen.swift
//  Nurtur
//
//  Created by sushant tiwari on 18/02/26.
//

import SwiftUI

struct mainscreen: View {
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceBackground"))
                .frame(height: 200)
                .padding()
        }    }
}

#Preview {
    mainscreen()
        .preferredColorScheme(.dark)
}
