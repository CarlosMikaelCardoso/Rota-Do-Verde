import SwiftUI

struct VeiculosView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VeiculosViewModel()
    
    let onSelecionarVeiculo: (Veiculo) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if viewModel.carregando {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Carregando veículos...")
                                .foregroundColor(.secondary)
                        }
                    } else if let erro = viewModel.erro {
                        VStack(spacing: 14) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 42))
                                .foregroundColor(.orange)
                            
                            Text("Erro ao carregar veículos")
                                .font(.headline)
                            
                            Text(erro)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Tentar novamente") {
                                Task {
                                    await viewModel.carregarVeiculos()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if viewModel.veiculos.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "car.slash.fill")
                                .font(.system(size: 42))
                                .foregroundColor(.gray)
                            
                            Text("Nenhum veículo encontrado")
                                .font(.headline)
                            
                            Text("Não há veículos disponíveis no momento.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 18) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Escolha seu veículo")
                                        .font(.title2.bold())
                                    
                                    Text("Selecione um modelo para verificar compatibilidade com os pontos.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                
                                LazyVStack(spacing: 14) {
                                    ForEach(viewModel.veiculos) { veiculo in
                                        Button {
                                            onSelecionarVeiculo(veiculo)
                                            dismiss()
                                        } label: {
                                            VeiculoCardView(veiculo: veiculo)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                            .padding(.top)
                        }
                    }
                }
            }
            .navigationTitle("Veículos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.carregarVeiculos()
            }
        }
    }
}

struct VeiculoCardView: View {
    let veiculo: Veiculo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "bolt.car.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(veiculo.marca)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(veiculo.modelo)
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Conectores")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(veiculo.conectoresCompativeis, id: \.self) { conector in
                            Text(conector)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.12))
                                .foregroundColor(.green)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            HStack {
                Label("\(veiculo.potenciaMaxSuportadaKW) kW", systemImage: "bolt.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("Selecionar")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    VeiculosView { _ in }
}
