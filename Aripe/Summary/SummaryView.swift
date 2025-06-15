import SwiftUI

struct SummaryView: View {
    @ObservedObject var result: PredictionResult
    @Binding var navigateToSummary: Bool

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy – HH.mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: Date())
    }

    private var resultInfo: (title: String, description: String, color: Color) {
        switch result.label.lowercased() {
        case "unripe apple":
            return ("Belum Matang", "Apel masih keras dan belum manis", .orange)
        case "ripe apple":
            return ("Matang", "Siap dikonsumsi, rasa manis", .green)
        case "rotten apple":
            return ("Busuk", "Apel sudah tidak layak dikonsumsi", .red)
        case "not apple":
            return ("Tidak Dikenal", "Tidak bisa mendeteksi kondisi apel", .gray)
        default:
            return ("Hasil Tidak Dikenal", "Model tidak yakin hasilnya benar", .gray)
        }
    }

    private var isPredictionValid: Bool {
        let knownLabels = ["unripe apple", "ripe apple", "rotten apple", "not apple"]
        return result.image != nil && knownLabels.contains(result.label.lowercased()) && result.confidence > 0.0
    }

    var body: some View {
        
        headerSection
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = result.image, isPredictionValid {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                        .clipped()
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    
                    predictionSection
                    resultSection
//                    storageSection
//                    buttonSection
                } else {
                    VStack(alignment: .center, spacing: 12) {
                        Text("Foto tidak terdeteksi")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.title2)
                        Text("Silakan coba scan ulang dengan pencahayaan yang lebih baik.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 32)
        }
//        .navigationTitle("Hasil Scan")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(false)
    }
    
    private var headerSection: some View {
        HStack {
            Text("Hasil Scan")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Button {
                navigateToSummary = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
            }
        }
        .padding([.top, .horizontal])
    }
    
    private var predictionSection: some View {
        VStack(alignment: .leading) {
            Text(result.label)
                .font(.title2)
                .fontWeight(.bold)
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .padding(.horizontal)
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text("\(Int(result.confidence * 100))%")
                    .font(.title)
                    .bold()
                    .foregroundColor(resultInfo.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(resultInfo.title)
                        .font(.headline)
                        .foregroundColor(resultInfo.color)
                    Text(resultInfo.description)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(resultInfo.color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
//    MARK : NOT USED!
    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Lokasi Penyimpanan Ideal", systemImage: "thermometer")
                .font(.headline)

            Text("20–22°C")
                .font(.subheadline)
                .foregroundColor(.gray)

            infoSection(title: "Estimasi ketahanan",
                        content: "- Dalam Kulkas: tahan 7 hari\n- Suhu ruang: 2 hari lagi sebelum terlalu matang")

            infoSection(title: "Jika apel sudah dipotong",
                        content: "- Simpan potongan apel di wadah tertutup di kulkas.\n- Tambahkan air lemon atau air garam agar tidak cepat kecokelatan.")

            infoSection(title: "Tips lainnya",
                        content: "Jangan simpan apel di dekat pisang atau alpukat agar tidak cepat matang.\nGunakan kantong kertas untuk mempercepat kematangan jika ingin cepat dimakan.")
        }
        .padding(.horizontal)
    }

    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var buttonSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                // Back or rescan
            }) {
                Text("Scan Ulang")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }

            Button(action: {
                // Save action
            }) {
                Text("Simpan Apel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}
