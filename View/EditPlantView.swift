//
//  EditPlantView.swift
//  Nurtur
//
//  Created by sushant tiwari on 21/02/26.
//

import SwiftUI

struct EditPlantView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var name: String
    @State var frequency: Int
    var onSave: (String, Int) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Plant Name")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Watering Frequency (days)")) {
                    Stepper(value: $frequency, in: 1...30) {
                        Text("\(frequency) days")
                    }
                }
            }
            .navigationTitle("Edit Plant")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, frequency)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditPlantView(
            name: "Monstera",
            frequency: 3,
            onSave: { _, _ in
                print("Save tapped")
            }
        )
    }
}
