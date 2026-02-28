//
//  mainscreen.swift
//  Nurtur
//
//  Created by sushant tiwari on 18/02/26.
//

import SwiftUI

struct HomeView: View {

    @State private var showAddPlant = false
    @State private var searchText = ""
    @State private var showSearch = false

    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                List {

                    // MARK: Header Section
                    Section {
                        headerContent
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                    // MARK: Weather Section
                    if let weather = viewModel.weather {
                        Section {
                            WeatherCardView(
                                temperature: weather.main.temp - 273.15,
                                humidity: weather.main.humidity,
                                condition: weather.name
                            )
                            .padding(.vertical, 8)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }

                    // MARK: Plant Sections

                    if !filteredOverduePlants().isEmpty {
                        plantSection(
                            title: "Overdue",
                            color: .red,
                            plants: filteredOverduePlants()
                        )
                    }

                    if !filteredTodayPlants().isEmpty {
                        plantSection(
                            title: "Due Today",
                            color: Color("AccentLight"),
                            plants: filteredTodayPlants()
                        )
                    }

                    if !filteredUpcomingPlants().isEmpty {
                        plantSection(
                            title: "Upcoming",
                            color: Color("TextSecondary"),
                            plants: filteredUpcomingPlants()
                        )
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        Button {
                            showAddPlant = true
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
                AddPlantView { name, frequency, imagePath in
                    viewModel.addPlant(
                        name: name,
                        frequency: frequency,
                        imagePath: imagePath
                    )
                }
            }
        }
    }
}
private extension HomeView {

    var headerContent: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Nurtur")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))

                Spacer()

                Button {
                    withAnimation(.easeInOut) {
                        showSearch.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color("SurfaceBackground"))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color("AccentGreen").opacity(0.2), lineWidth: 1)
                        )
                }
            }

            Text("Care for your green companions")
                .foregroundColor(Color("TextSecondary"))

            if showSearch {
                TextField("Search plants", text: $searchText)
                    .padding()
                    .background(Color("SurfaceBackground"))
                    .cornerRadius(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
    }
}
private extension HomeView {

    func plantSection(title: String, color: Color, plants: [Plant]) -> some View {
        Section {
            ForEach(plants) { plant in
                plantRow(plant)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        } header: {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}
private extension HomeView {

    // MARK: - Filtering

    func filteredOverduePlants() -> [Plant] {
        filter(plants: viewModel.overduePlants)
    }

    func filteredTodayPlants() -> [Plant] {
        filter(plants: viewModel.todayPlants)
    }

    func filteredUpcomingPlants() -> [Plant] {
        filter(plants: viewModel.upcomingPlants)
    }

    func filter(plants: [Plant]) -> [Plant] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return plants }

        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }

    // MARK: - Plant Row

    @ViewBuilder
    func plantRow(_ plant: Plant) -> some View {
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

    // MARK: - Binding

    func binding(for plant: Plant) -> Binding<Plant> {
        guard let index = viewModel.plants.firstIndex(where: { $0.id == plant.id }) else {
            fatalError("Plant not found")
        }
        return $viewModel.plants[index]
    }
}
