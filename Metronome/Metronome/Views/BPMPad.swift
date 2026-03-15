//
//  BPMPad.swift
//  Metronome
//

import SwiftUI

struct BPMPad: View {
    @Environment(MetronomeEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    @State private var inputString: String = ""

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(inputString.isEmpty ? "0" : inputString)
                .font(.system(size: 60, weight: .thin, design: .rounded))
                .frame(maxWidth: .infinity)

            digitGrid

            confirmButton

            Spacer()
        }
        .padding()
        .onAppear {
            inputString = "\(Int(engine.bpm))"
        }
    }

    // MARK: - Digit Grid

    private var digitGrid: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                digitButton("7")
                digitButton("8")
                digitButton("9")
            }
            GridRow {
                digitButton("4")
                digitButton("5")
                digitButton("6")
            }
            GridRow {
                digitButton("1")
                digitButton("2")
                digitButton("3")
            }
            GridRow {
                cancelButton
                digitButton("0")
                backspaceButton
            }
        }
    }

    // MARK: - Buttons

    private func digitButton(_ digit: String) -> some View {
        Button {
            guard inputString.count < 3 else { return }
            inputString.append(digit)
        } label: {
            Text(digit)
                .font(.title)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.bordered)
    }

    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }

    private var backspaceButton: some View {
        Button {
            guard !inputString.isEmpty else { return }
            inputString.removeLast()
        } label: {
            Image(systemName: "delete.backward")
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.bordered)
    }

    private var confirmButton: some View {
        Button {
            if let value = Double(inputString) {
                engine.setBPM(value)
            }
            dismiss()
        } label: {
            Image(systemName: "checkmark")
                .font(.title)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    BPMPad()
        .environment(MetronomeEngine())
}
