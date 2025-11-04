import SwiftUI

/// Compatibility wrapper that keeps legacy references working while the new implementation lives in `FavoritesHistoryView`.
struct FavoritesAndHistoryView: View {
    var body: some View {
        FavoritesHistoryView()
    }
}
