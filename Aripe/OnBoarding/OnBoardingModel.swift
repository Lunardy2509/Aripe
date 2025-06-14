//
//  OnBoardingModel.swift
//  Aripe
//
//  Created by Reynard Hansel on 14/06/25.
//

import Foundation
import DeveloperToolsSupport

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

let pagesContent: [OnboardingPage] = [
    OnboardingPage(
        imageName: "onboard1",
        title: "Apa itu Matengin?",
        description:
            "Matengin membantumu mengecek tingkat kematangan apel agar kamu tahu kapan buah siap dimakan."
    ),
    OnboardingPage(
        imageName: "onboard2",
        title: "Scan Buah",
        description:
            "Cukup foto apelmu, dan dapatkan estimasi waktu konsumsi supaya buah nggak terbuang sia‑sia."
    ),
    OnboardingPage(
        imageName: "onboard3",
        title: "Simpan buahmu ke basket",
        description:
            "Kamu bisa menyimpan buah yang kamu beli ke dalam basket agar kami dapat memantau estimasi hari apelmu."
    ),
]
