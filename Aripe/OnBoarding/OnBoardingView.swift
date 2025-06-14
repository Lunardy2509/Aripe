//
//  OnBoardingView.swift
//  Aripe
//
//  Created by Reynard Hansel on 14/06/25.
//

import SwiftUI

struct OnBoardingView: View {
    let pages = pagesContent

    // Track the current page
    @State private var currentPage = 0

    // Dismiss or mark onboarding done
    var onFinished: (() -> Void)? = nil

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.1.id) {
                    index,
                    page in
                    VStack(spacing: 20) {
                        // Image container with rounded background
                        ZStack {
                            // Rounded rectangle background (light cream)
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    Color(
                                        red: 254 / 255,
                                        green: 242 / 255,
                                        blue: 221 / 255
                                    )
                                )
                                .frame(
                                    width: UIScreen.main.bounds.width * 0.8,
                                    height: UIScreen.main.bounds.height * 0.4
                                )

                            // The illustration image
                            Image(page.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: UIScreen.main.bounds.width * 0.6,
                                    height: 250
                                )
                        }

                        // Title
                        Text(page.title)
                            .font(.title2).bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        // Description
                        Text(page.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                    }
                    .tag(index)
                }
            }
//            .tabViewStyle(PageTabViewStyle())
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Custom page indicator
//            HStack(spacing: 8) {
//                ForEach(0..<pages.count, id: \.self) { idx in
//                    Circle()
//                        .fill(
//                            idx == currentPage
//                                ? Color.primary : Color.gray.opacity(0.4)
//                        )
//                        .frame(width: 8, height: 8)
//                }
//            }

            // “Selesai” button on last page
            Button(action: {
                if currentPage == pages.count - 1 {
                    onFinished?()
                }
            }) {
                Text("Selesai")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
//                    .frame(height: 50)
                    .background(.aPrimaryGreen)
                    .cornerRadius(12)
            }
            .opacity(currentPage == pages.count - 1 ? 1 : 0)
            .disabled(currentPage != pages.count - 1)
            .padding(.horizontal, 30)
            .padding(.top, 16)
            .padding(.bottom, 40)

        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    OnBoardingView()
}
