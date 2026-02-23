//
//  mainscreen.swift
//  Nurtur
//
//  Created by sushant tiwari on 18/02/26.
//

import SwiftUI

struct HomeView: View {
    @State private var showAddPlant = false
    @State private var searchText =  ""
    @StateObject private var viewModel = HomeViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nurtur")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Care for your green companions")
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search plants", text: $searchText)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding()
                    .background(Color("SurfaceBackground"))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Content Area
                    Group {
                        if viewModel.plants.isEmpty {
                            
                            VStack {
                                Spacer()
                                
                                VStack(spacing: 16) {
                                    Image(systemName: "leaf")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color("AccentLight"))
                                    
                                    Text("No plants yet")
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                    
                                    Text("Tap the + button to add your first plant")
                                        .font(.subheadline)
                                        .foregroundColor(Color("TextSecondary"))
                                }
                                
                                Spacer()
                            }
                            
                        } else {
                            
                            List {

                                if !filteredOverduePlants().isEmpty {
                                    Section{
                                        ForEach(filteredOverduePlants()) { plant in
                                            plantRow(plant)
                                        }
                                    }
                                    header: {
                                        Text("Overdue")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                    }
                                }

                                if !filteredTodayPlants().isEmpty {
                                    Section {
                                        ForEach(filteredTodayPlants()) { plant in
                                            plantRow(plant)
                                        }
                                    }
                                    header: {
                                        Text("Due Today")
                                            .font(.headline)
                                            .foregroundColor(Color("AccentLight"))
                                    }
                                }
                                if !filteredUpcomingPlants().isEmpty {
                                    Section {
                                        ForEach(filteredUpcomingPlants()) { plant in
                                            plantRow(plant)
                                        }
                                    }
                                    header: {
                                        Text("Upcoming")
                                            .font(.headline)
                                            .foregroundColor(Color("TextSecondary"))
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .scrollContentBackground(.hidden)
                            
                          
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
         
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                           showAddPlant=true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color("AccentGreen"))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showAddPlant) {
                AddPlantView { name, frequency in
                    viewModel.addPlant(name: name, frequency: frequency)
                }
            }
        }
    }
    @ViewBuilder
    private func plantRow(_ plant: Plant) -> some View {
        NavigationLink {
            PlantDetailView(
                plant: binding(for: plant),
                onWater: {
                    viewModel.markAsWatered(plant)
                },
                onEdit: { name, frequency in
                    viewModel.updatePlant(plant, name: name, frequency: frequency)
                }
            )
        } label: {
            PlantCardView(plant: plant) { }
        }
        .swipeActions {
              Button(role: .destructive) {
                  viewModel.deletePlant(plant)
              } label: {
                  Label("Delete", systemImage: "trash")
              }
          }
    }
    
    private func filteredOverduePlants() -> [Plant] {
        filter(plants: viewModel.overduePlants)
    }

    private func filteredTodayPlants() -> [Plant] {
        filter(plants: viewModel.todayPlants)
    }

    private func filteredUpcomingPlants() -> [Plant] {
        filter(plants: viewModel.upcomingPlants)
    }

    private func filter(plants: [Plant]) -> [Plant] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return plants }
        return plants.filter { plant in
            plant.name.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
    private func binding(for plant: Plant) -> Binding<Plant> {
        guard let index = viewModel.plants.firstIndex(where: { $0.id == plant.id }) else {
            fatalError("Plant not found")
        }
        return $viewModel.plants[index]
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
