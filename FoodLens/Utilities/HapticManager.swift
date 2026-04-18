// HapticManager.swift
// FoodLens - Utility
//
// Handles all haptic feedback throughout the app

import UIKit
import SwiftUI

final class HapticManager {
    // MARK: - Singleton
    
    static let shared = HapticManager()
    
    // MARK: - Feedback Generators
    
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    // MARK: - Initialization
    
    init() {
        // Prepare generators for minimal latency
        impact.prepare()
        notification.prepare()
        selection.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// Light impact (e.g., button tap)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact (e.g., swipe action)
    func medium() {
        impact.impactOccurred()
    }
    
    /// Heavy impact (e.g., delete action)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Success feedback (e.g., meal logged)
    func success() {
        notification.notificationOccurred(.success)
    }
    
    /// Warning feedback (e.g., over target)
    func warning() {
        notification.notificationOccurred(.warning)
    }
    
    /// Error feedback (e.g., operation failed)
    func error() {
        notification.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Selection changed (e.g., picker, segmented control)
    func selectionChanged() {
        selection.selectionChanged()
    }
    
    // MARK: - Contextual Feedback
    
    /// Meal logged successfully
    func mealLogged() {
        success()
    }
    
    /// Meal deleted
    func mealDeleted() {
        light()
    }
    
    /// Target reached
    func targetReached() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Double tap for celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
    
    /// Target exceeded
    func targetExceeded() {
        warning()
    }
    
    /// Onboarding completed
    func onboardingCompleted() {
        success()
        
        // Triple tap for major milestone
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.success()
        }
    }
    
    /// Search result tap
    func searchResultTapped() {
        light()
    }
    
    /// Favorite toggled
    func favoriteToggled() {
        medium()
    }
}

// MARK: - SwiftUI Environment Key

struct HapticManagerKey: EnvironmentKey {
    static let defaultValue = HapticManager.shared
}

extension EnvironmentValues {
    var hapticManager: HapticManager {
        get { self[HapticManagerKey.self] }
        set { self[HapticManagerKey.self] = newValue }
    }
}
