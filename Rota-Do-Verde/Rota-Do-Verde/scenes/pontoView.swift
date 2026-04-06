import SwiftUI

struct sheetView: View {
    let local: location
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                // Imagem (usando um placeholder caso a string esteja vazia)
                if let imageUrl = URL(string: local.foto) {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            // Se a URL falhar ou não houver internet
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, minHeight: 250)
                                .background(Color.gray.opacity(0.1))
                        case .empty:
                            // Enquanto carrega (Loading)
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(15)
                    .padding(.horizontal)
                } else {
                    // Caso a string 'foto' esteja vazia ou mal formatada
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 250)
                        .overlay(Text("URL da imagem inválida"))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(local.nome)
                        .font(.largeTitle)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(local.descricao)
                        .font(.body)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 40)
                }
                .padding()
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle(local.nome) // Título na nova página
        .navigationBarTitleDisplayMode(.inline)
    }
}
