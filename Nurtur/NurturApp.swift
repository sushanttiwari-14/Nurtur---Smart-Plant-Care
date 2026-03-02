//
//  NurturApp.swift
//  Nurtur
//
//  Created by sushant tiwari on 18/02/26.
//

import SwiftUI
import UserNotifications

@main
struct NurturApp: App {

    @StateObject private var homeViewModel = HomeViewModel()

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(homeViewModel)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("Permission requested")
        }
    }
}
