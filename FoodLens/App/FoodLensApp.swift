// FoodLensApp.swift
// FoodLens - App Entry Point
//
// Sets up Clean Architecture dependencies and SwiftData

import SwiftUI
import SwiftData

@main
struct FoodLensApp: App {
    // MARK: - Properties
    
    /// Centralized app state (Redux-like)
    @State private var appState = AppState.shared
    
    /// SwiftData container
    let modelContainer: ModelContainer
    
    /// Repositories (Data Access Layer)
    @State private var foodRepository: FoodRepository
    @State private var mealLogRepository: MealLogRepository
    
    /// Interactors (Business Logic Layer)
    @State private var foodSearchInteractor: FoodSearchInteractor
    @State private var mealLoggingInteractor: MealLoggingInteractor
    @State private var settingsInteractor: SettingsInteractor

    private static let appSchema = Schema([
        FoodItem.self,
        MealEntry.self,
        DailyLog.self,
        UserSettings.self
    ])
    
    // MARK: - Initialization
        
        init() {
            // 1. Setup SwiftData
            do {
                modelContainer = try Self.makeModelContainer()
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
            
            // 2. Initialize repositories
            let context = modelContainer.mainContext
            
            // Create local instances first
            let localFoodRepo = FoodRepository(modelContext: context)
            let localMealRepo = MealLogRepository(modelContext: context)
            
            // Initialize the @State properties using the underscore syntax
            _foodRepository = State(initialValue: localFoodRepo)
            _mealLogRepository = State(initialValue: localMealRepo)
            
            // 3. Initialize interactors
            let state = AppState.shared
            
            _foodSearchInteractor = State(initialValue: FoodSearchInteractor(
                appState: state,
                foodRepository: localFoodRepo
            ))
            
            _mealLoggingInteractor = State(initialValue: MealLoggingInteractor(
                appState: state,
                mealLogRepository: localMealRepo,
                foodRepository: localFoodRepo
            ))

            _settingsInteractor = State(initialValue: SettingsInteractor(
                appState: state,
                modelContext: context
            ))
        }

    private static func makeModelContainer() throws -> ModelContainer {
        let modelConfiguration = ModelConfiguration(
            schema: appSchema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: appSchema,
                configurations: [modelConfiguration]
            )
        } catch {
            print("❌ SwiftData failed to load persistent store: \(error)")

            guard clearIncompatiblePersistentStore() else {
                throw error
            }

            print("🧹 Removed incompatible SwiftData store. Retrying with a clean store.")

            return try ModelContainer(
                for: appSchema,
                configurations: [modelConfiguration]
            )
        }
    }

    private static func clearIncompatiblePersistentStore() -> Bool {
        let fileManager = FileManager.default
        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return false
        }

        let storePrefix = "default.store"
        let candidateURLs: [URL]

        if let existingURLs = try? fileManager.contentsOfDirectory(
            at: applicationSupportURL,
            includingPropertiesForKeys: nil
        ) {
            candidateURLs = existingURLs.filter { $0.lastPathComponent.hasPrefix(storePrefix) }
        } else {
            let baseStoreURL = applicationSupportURL.appendingPathComponent(storePrefix)
            candidateURLs = [
                baseStoreURL,
                URL(fileURLWithPath: baseStoreURL.path + "-shm"),
                URL(fileURLWithPath: baseStoreURL.path + "-wal")
            ]
        }

        var removedAnyStoreFile = false

        for url in candidateURLs where fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
                removedAnyStoreFile = true
            } catch {
                print("⚠️ Failed to remove store file at \(url.path): \(error)")
            }
        }

        return removedAnyStoreFile
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(\.modelContext, modelContainer.mainContext)
                .environment(foodSearchInteractor)
                .environment(mealLoggingInteractor)
                .environment(settingsInteractor)
                .task {
                    await initializeApp()
                }
        }
        .modelContainer(modelContainer)
    }
    
    // MARK: - Setup
    
    /// Initialize app on launch
    private func initializeApp() async {
        // 1. Seed database if needed
        do {
            try await foodRepository.seedDatabase()
        } catch {
            print("❌ Failed to seed database: \(error)")
        }
        
        // 2. Load user settings
        await loadUserSettings()
        
        // 3. Load today's data
        await loadTodayData()
    }
    
    private func loadUserSettings() async {
        let context = modelContainer.mainContext
        
        do {
            let descriptor = FetchDescriptor<UserSettings>()
            let settings = try context.fetch(descriptor)
            
            if let firstSettings = settings.first {
                await MainActor.run {
                    appState.userSettings = firstSettings
                    
                    // Set routing based on onboarding state
                    if !firstSettings.hasCompletedOnboarding {
                        appState.routing = .onboarding
                    }
                }
            } else {
                // Create default settings
                let defaultSettings = UserSettings()
                context.insert(defaultSettings)
                try context.save()
                
                await MainActor.run {
                    appState.userSettings = defaultSettings
                    appState.routing = .onboarding
                }
            }
        } catch {
            print("❌ Failed to load user settings: \(error)")
            // Create default settings as fallback
            let defaultSettings = UserSettings()
            context.insert(defaultSettings)
            try? context.save()
            
            await MainActor.run {
                appState.userSettings = defaultSettings
                appState.routing = .onboarding
            }
        }
    }
    
    private func loadTodayData() async {
        do {
            // Load today's meals
            let todayMeals = try await mealLogRepository.fetchToday()
            
            // Load recents and favorites
            let recentFoods = try await foodRepository.fetchRecentFoods()
            let favoriteFoods = try await foodRepository.fetchFavorites()
            
            await MainActor.run {
                appState.updateTodayMeals(todayMeals)
                appState.updateRecentFoods(recentFoods)
                appState.updateFavoriteFoods(favoriteFoods)
            }
        } catch {
            print("❌ Failed to load today's data: \(error)")
        }
    }
}

// MARK: - Content View (Root Navigation)

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(MealLoggingInteractor.self) private var mealLoggingInteractor
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddMeal = false
    
    var body: some View {
        Group {
            switch appState.routing {
            case .onboarding:
                OnboardingCoordinator()
            case .today, .add, .history, .settings:
                mainTabView
            }
        }
        .environment(appState)
    }
    
    private var mainTabView: some View {
        TabView(selection: .init(
            get: { appState.routing },
            set: { newValue in
                // Intercept the "add" tab selection to show sheet instead
                if case .add = newValue {
                    showingAddMeal = true
                    // Don't change the routing - stay on current tab
                } else {
                    appState.routing = newValue
                }
            }
        )) {
            TodayView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.Routing.today)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(AppState.Routing.history)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppState.Routing.settings)

            // Rightmost "+" tab (separated group)
            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(AppState.Routing.add)
         }
        .sheet(isPresented: $showingAddMeal) {
            LogMealSheet(initialMealType: mealLoggingInteractor.suggestedMealType()) {
                // Refresh data after logging
                Task {
                    await refreshData()
                }
            }
        }
    }
    
    private func refreshData() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let todayDescriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate { meal in
                meal.timestamp >= startOfDay
            },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        var recentFoodsDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { food in
                food.lastUsedDate != nil
            },
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        recentFoodsDescriptor.fetchLimit = 10

        let favoriteFoodsDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { food in
                food.isFavorite == true
            },
            sortBy: [SortDescriptor(\.foodName)]
        )

        do {
            let todayMeals = try modelContext.fetch(todayDescriptor)
            let recentFoods = try modelContext.fetch(recentFoodsDescriptor)
            let favoriteFoods = try modelContext.fetch(favoriteFoodsDescriptor)

            await MainActor.run {
                appState.updateTodayMeals(todayMeals)
                appState.updateRecentFoods(recentFoods)
                appState.updateFavoriteFoods(favoriteFoods)
            }
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
}

// MARK: - Onboarding Coordinator

struct OnboardingCoordinator: View {
    var body: some View {
        NavigationStack {
            OnboardingWelcomeView()
        }
    }
}

