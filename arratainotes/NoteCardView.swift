import SwiftUI

struct NoteCardView: View {
    @EnvironmentObject var vm: NotesViewModel
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                
                if note.isBookmarked {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
            }
            
            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                .font(AppTheme.rounded(17, weight: .bold, base: vm.appFontSize))
                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                .lineLimit(2)
            
            Text(note.content)
                .font(AppTheme.rounded(13, base: vm.appFontSize))
                .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.6))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 12)
            
            HStack {
                Text(note.createdAt, style: .date)
                    .font(AppTheme.rounded(11, weight: .medium, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.3))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.2))
            }
        }
        .padding(18)
        .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct FolderCardView: View {
    @EnvironmentObject var vm: NotesViewModel
    let title: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.folderYellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.rounded(16, weight: .bold, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme))
                
                Text("\(count) items")
                    .font(AppTheme.rounded(12, weight: .medium, base: vm.appFontSize))
                    .foregroundColor(AppTheme.textColor(for: vm.appearanceTheme).opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.cardBackgroundColor(for: vm.appearanceTheme))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
