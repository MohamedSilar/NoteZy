import SwiftUI

@main
struct arratainotesApp: App {
    @StateObject var vm = NotesViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(vm)
                    .preferredColorScheme(colorScheme)
                    .blur(radius: vm.isLocked ? 20 : 0)
                
                if vm.isLocked {
                    LockScreenView()
                        .environmentObject(vm)
                        .transition(.opacity)
                }
            }
            .animation(.spring(), value: vm.isLocked)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
                    if vm.isFaceIDEnabled {
                        vm.isLocked = true
                    }
                }
            }
        }
    }
    
    var colorScheme: ColorScheme? {
        switch vm.appearanceTheme {
        case "Light": return .light
        case "Dark": return .dark
        default: return .dark // Purple is a dark theme
        }
    }
}

struct LockScreenView: View {
    @EnvironmentObject var vm: NotesViewModel
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor(for: "Purple").ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(AppTheme.accent)
                }
                
                VStack(spacing: 8) {
                    Text("NoteZy is Locked")
                        .font(AppTheme.rounded(24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Use FaceID to unlock your notes")
                        .font(AppTheme.rounded(16))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                Button {
                    vm.authenticate()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.title2)
                        Text("Unlock with FaceID")
                            .font(AppTheme.rounded(18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            vm.authenticate()
        }
    }
}
