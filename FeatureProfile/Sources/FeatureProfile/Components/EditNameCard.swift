import SwiftUI
import DesignSystem

/// Edit-name section: two text fields (first / last) that let the user change
/// the default display name. Pre-fills from the current name and calls the
/// provided async action (backed by `ProfileViewModel.updateName`) on save.
struct EditNameCard: View {
    @Environment(\.appPalette) private var palette
    @State private var firstName: String
    @State private var lastName: String
    @FocusState private var focused: Field?
    let isWorking: Bool
    let onSubmit: (String, String) async -> Void

    private enum Field { case first, last }

    init(
        firstName: String,
        lastName: String,
        isWorking: Bool,
        onSubmit: @escaping (String, String) async -> Void
    ) {
        _firstName = State(initialValue: firstName)
        _lastName = State(initialValue: lastName)
        self.isWorking = isWorking
        self.onSubmit = onSubmit
    }

    private var canSubmit: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty && !isWorking
    }

    var body: some View {
        ProfileCard(title: L10n.Card.yourName) {
            VStack(spacing: 12) {
                textField(L10n.Field.firstName, text: $firstName, field: .first, icon: "person.fill")
                profileDivider(palette)
                textField(L10n.Field.lastName, text: $lastName, field: .last, icon: "person")
                submitButton
            }
            .padding(.vertical, 6)
        }
    }

    private func textField(
        _ prompt: String,
        text: Binding<String>,
        field: Field,
        icon: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(palette.brandPrimary)
                .frame(width: 28)
            TextField(prompt, text: text)
                .textContentType(field == .first ? .givenName : .familyName)
                .autocorrectionDisabled()
                .focused($focused, equals: field)
                .foregroundStyle(palette.textPrimary)
                .onChange(of: text.wrappedValue) { _, newValue in
                    let cap = ProfileViewModel.maxNameFieldLength
                    if newValue.count > cap {
                        text.wrappedValue = String(newValue.prefix(cap))
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var submitButton: some View {
        Button {
            Task {
                await onSubmit(firstName, lastName)
                focused = nil
            }
        } label: {
            HStack(spacing: 8) {
                if isWorking { ProgressView().controlSize(.small) }
                Text(L10n.Action.saveName).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(palette.brandPrimary)
        .disabled(!canSubmit)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}
