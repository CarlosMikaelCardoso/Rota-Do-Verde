import SwiftUI

struct pontoView: View {
    let local: PontoRecarga
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                // Placeholder genérico já que não há foto no PontoRecargaModel
                Image(systemName: "bolt.car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, minHeight: 250)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(local.nome)
                        .font(.largeTitle)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(local.descricao ?? "Sem descrição disponível.")
                        .font(.body)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 40)
                    
                    Text("Endereço: \(local.endereco)")
                        .font(.subheadline)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                }
                .padding()
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle(local.nome)
        .navigationBarTitleDisplayMode(.inline)
    }
}
