//
//  StartView.swift
//  EmojiFaceDodge
//
//  Created by Five Exceptions on 02/04/26.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let titleSize = min(52, width * 0.12)

            ZStack {
                Group {
                    homeBackground
                    ambientGlow(width: width, height: height)
                    floatingEmojiDecor(width: width, height: height)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar
                        .padding(.bottom, 8)

                    Spacer(minLength: 24)

                    VStack(spacing: 14) {
                        Text("Emoji Face Dodge")
                            .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.65)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
                            .shadow(color: .indigo.opacity(0.45), radius: 16, y: 0)

                        Text("Lane dodge")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.72))
                            .tracking(3)
                            .textCase(.uppercase)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)

                    VStack(spacing: 22) {
                        howToPlayCard

                        playButton
                            .padding(.horizontal, 28)
                    }

                    Spacer(minLength: 32)

                    Text("Tap play — drag side to side to dodge.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var homeBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.15, green: 0.09, blue: 0.35),
                Color.indigo.opacity(0.92),
                Color.purple.opacity(0.75),
                Color(red: 0.2, green: 0.35, blue: 0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func ambientGlow(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RadialGradient(
                colors: [.cyan.opacity(0.22), .clear],
                center: .topLeading,
                startRadius: 40,
                endRadius: width * 0.85
            )
            RadialGradient(
                colors: [.pink.opacity(0.12), .clear],
                center: UnitPoint(x: 0.9, y: 0.25),
                startRadius: 20,
                endRadius: height * 0.45
            )
        }
        .allowsHitTesting(false)
    }

    private func floatingEmojiDecor(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            decorEmoji("😀", x: width * 0.12, y: height * 0.22, rotation: -12, scale: 1.0)
            decorEmoji("🎯", x: width * 0.88, y: height * 0.28, rotation: 8, scale: 0.92)
            decorEmoji("⚡️", x: width * 0.18, y: height * 0.72, rotation: 6, scale: 0.85)
            decorEmoji("🎮", x: width * 0.82, y: height * 0.68, rotation: -6, scale: 0.88)
        }
        .allowsHitTesting(false)
    }

    private func decorEmoji(_ s: String, x: CGFloat, y: CGFloat, rotation: Double, scale: CGFloat) -> some View {
        Text(s)
            .font(.system(size: 38))
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(0.28)
            .blur(radius: 0.5)
            .position(x: x, y: y)
    }

    private var headerBar: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text("Home")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(.white.opacity(0.12))
                Capsule()
                    .strokeBorder(.white.opacity(0.22), lineWidth: 1)
            }
            .accessibilityHidden(true)

            Spacer(minLength: 12)

            soundToggleButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var soundToggleButton: some View {
        Button {
            appModel.isSoundEnabled.toggle()
            SoundManager.playButtonTap(isEnabled: appModel.isSoundEnabled)
        } label: {
            Image(systemName: appModel.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background {
                    Circle()
                        .fill(.white.opacity(0.16))
                    Circle()
                        .strokeBorder(.white.opacity(0.32), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityLabel(appModel.isSoundEnabled ? "Mute music and sounds" : "Unmute music and sounds")
    }

    private var howToPlayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "hand.draw.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.cyan.opacity(0.95))
                Text("How to play")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            (
                Text("You have ")
                    + Text("five lanes").fontWeight(.bold).foregroundStyle(.white)
                + Text(". Emojis fall straight down — ")
                    + Text("drag").fontWeight(.bold).foregroundStyle(.cyan.opacity(0.95))
                + Text(" anywhere on the screen to slide your character and stay clear.")
            )
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(.white.opacity(0.88))
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.42))
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .padding(.horizontal, 20)
    }

    private var playButton: some View {
        Button {
            SoundManager.playButtonTap(isEnabled: appModel.isSoundEnabled)
            appModel.startGame()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 20, weight: .bold))
                Text("Play")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.15, blue: 0.45), Color.indigo.opacity(0.92)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.28), radius: 14, y: 7)
            .shadow(color: .cyan.opacity(0.12), radius: 20, y: 0)
        }
        .buttonStyle(ScaleOnPressStyle())
        .accessibilityHint("Starts the game")
    }
}

// MARK: - Press feedback

private struct ScaleOnPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    StartView()
        .environmentObject(AppModel())
}
