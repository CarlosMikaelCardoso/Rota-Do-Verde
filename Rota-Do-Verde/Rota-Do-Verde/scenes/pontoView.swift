import SwiftUI

struct PontoView: View {
    let pontoId: String
    @StateObject private var viewModel = PontosViewModel()
    
    var body: some View {
        Group {
            if viewModel.carregando {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Carregando informações do ponto...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let erro = viewModel.erro {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Erro ao carregar o ponto")
                        .font(.headline)
                    
                    Text(erro)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let ponto = viewModel.pontoSelecionado {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(spacing: 12) {
                            Image(systemName: "bolt.car.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                            
                            Text(ponto.nome)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(statusFormatado(ponto.status))
                                .font(.subheadline)
                                .foregroundColor(corStatus(ponto.status))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(corStatus(ponto.status).opacity(0.12))
                                .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                        
                        Group {
                            blocoTitulo("Endereço")
                            Text(ponto.endereco)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        if let descricao = ponto.descricao, !descricao.isEmpty {
                            Group {
                                blocoTitulo("Descrição")
                                Text(descricao)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Group {
                            blocoTitulo("Conectores")
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(ponto.conectores.enumerated()), id: \.offset) { _, conector in
                                    HStack {
                                        Text(conector.tipo)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(conector.potenciaKW) kW")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Group {
                            blocoTitulo("Serviços")
                            
                            if ponto.servicos.isEmpty {
                                Text("Nenhum serviço informado")
                                    .foregroundColor(.secondary)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(ponto.servicos, id: \.self) { servico in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text(servico.capitalized)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Group {
                            blocoTitulo("Última atualização")
                            Text(ponto.ultimaAtualizacao ?? "Não informada")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                .navigationTitle(ponto.nome)
                .navigationBarTitleDisplayMode(.inline)
                
            } else {
                VStack {
                    Text("Ponto não encontrado")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.carregarPontoPorId(pontoId)
        }
    }
    
    private func blocoTitulo(_ titulo: String) -> some View {
        Text(titulo)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    private func statusFormatado(_ status: String) -> String {
        switch status.lowercased() {
        case "funcionando":
            return "Funcionando"
        case "manutencao":
            return "Em manutenção"
        default:
            return status.capitalized
        }
    }
    
    private func corStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "funcionando":
            return .green
        case "manutencao":
            return .orange
        default:
            return .gray
        }
    }
}
