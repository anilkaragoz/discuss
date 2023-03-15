import SwiftUI

struct HudView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark").resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60).foregroundColor(.secondary)
            Text("misc.success").bold().foregroundColor(.secondary)
        }.frame(width: 100, height: 100).padding()
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
    }
}

struct HudView_Previews: PreviewProvider {
    static var previews: some View {
        HudView()
    }
}

struct Hud: ViewModifier {
    @Binding var show: Bool

    func body(content: Content) -> some View {
        content.overlay {
            if show {
                HudView()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.2), value: show).onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            withAnimation {
                                show = false
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func hud(show: Binding<Bool>) -> some View {
        modifier(Hud(show: show))
    }
}
