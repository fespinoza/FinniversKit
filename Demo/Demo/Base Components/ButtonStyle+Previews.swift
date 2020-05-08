//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import SwiftUI
import FinniversKit

@available(iOS 13.0.0, *)
struct ButtonStyleUsageDemoView: View {
    var body: some View {
        VStack(spacing: .spacingL) {
            Text("Buttons").font(.largeTitle)

            VStack(alignment: .leading, spacing: .spacingL) {
                Text("Call to Action").font(.headline)

                VStack(spacing: .spacingS) {
                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal") {}
                        .buttonStyle(CallToAction())

                        SwiftUI.Button("Disabled") {}
                        .buttonStyle(CallToAction(background: .btnDisabled))
                    }

                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal") {}
                        .buttonStyle(CallToAction(size: .small))

                        SwiftUI.Button("Disabled") {}
                        .buttonStyle(CallToAction(size: .small, background: .btnDisabled))
                    }
                }

                Text("Default").font(.headline)

                VStack(spacing: .spacingS) {
                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal") {}
                        .buttonStyle(DefaultStyle())

                        SwiftUI.Button("Disabled") {}
                        .disabled(true)
                        .buttonStyle(DefaultStyle(textColor: .btnDisabled))
                    }

                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal Small") {}
                        .buttonStyle(DefaultStyle(size: .small))

                        SwiftUI.Button("Disabled Small") {}
                        .disabled(true)
                        .buttonStyle(DefaultStyle(size: .small, textColor: .btnDisabled))
                    }
                }

                Text("Flat").font(.headline)

                VStack(spacing: .spacingS) {
                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal") {}
                        .buttonStyle(FlatStyle())

                        SwiftUI.Button("Disabled") {}
                        .disabled(true)
                        .buttonStyle(FlatStyle(textColor: .btnDisabled))
                    }

                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal Small") {}
                        .buttonStyle(FlatStyle(size: .small))

                        SwiftUI.Button("Disabled Small") {}
                        .disabled(true)
                        .buttonStyle(FlatStyle(size: .small, textColor: .btnDisabled))
                    }
                }

                Text("Inline Flat").font(.headline)

                VStack(alignment: .leading, spacing: .spacingS) {
                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal") {}
                        .buttonStyle(InlineFlatStyle())

                        SwiftUI.Button("Disabled") {}
                        .disabled(true)
                        .buttonStyle(InlineFlatStyle(textColor: .btnDisabled))
                    }

                    HStack(spacing: .spacingM) {
                        SwiftUI.Button("Normal Small") {}
                        .buttonStyle(InlineFlatStyle(size: .small))

                        SwiftUI.Button("Disabled Small") {}
                        .disabled(true)
                        .buttonStyle(InlineFlatStyle(size: .small, textColor: .btnDisabled))
                    }
                }

                Spacer()
            }
        }
        .padding()
    }
}

@available(iOS 13.0.0, *)
struct ButtonStyleUsageDemoView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonStyleUsageDemoView()
    }
}
