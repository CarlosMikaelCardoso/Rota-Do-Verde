import SwiftUI

struct PontoView: View {
    let pontoId: String
    var onRouteRequested: (() -> Void)?
    
    @StateObject private var viewModel = PontosViewModel()
    
    @State private var mostrarPopupSucesso = false
    @State private var mostrarPopupErro = false
    @State private var mostrarTelaEditar = false
    
    var body: some View {
        Group {
            if viewModel.carregando && viewModel.pontoSelecionado == nil {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Carregando informações do ponto...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let erro = viewModel.erro, viewModel.pontoSelecionado == nil {
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
                ZStack(alignment: .bottomTrailing) {
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
                                
                                Text(statusVisual(ponto))
                                    .font(.subheadline)
                                    .foregroundColor(corStatusVisual(ponto))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(corStatusVisual(ponto).opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                            
                            Group {
                                blocoTitulo("Endereço")
                                Text(ponto.endereco)
                                    .font(.body)
                            }
                            
                            if let descricao = ponto.descricao, !descricao.isEmpty {
                                Group {
                                    blocoTitulo("Descrição")
                                    Text(descricao)
                                        .font(.body)
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
                            
                            Group {
                                blocoTitulo("Uso do ponto")
                                
                                if ponto.status.lowercased() == "manutencao" {
                                    Text("Este ponto está em manutenção e não pode ser ocupado.")
                                        .foregroundColor(.orange)
                                    
                                    Button("Indisponível") {}
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.gray)
                                        .cornerRadius(12)
                                        .disabled(true)
                                } else if ponto.ocupado == true {
                                    Button {
                                        Task {
                                            let sucesso = await viewModel.desocuparPonto(ponto.id)
                                            if sucesso {
                                                mostrarPopupSucesso = true
                                            } else {
                                                mostrarPopupErro = true
                                            }
                                        }
                                    } label: {
                                        if viewModel.carregando {
                                            ProgressView()
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                        } else {
                                            Text("Desocupar ponto")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                        }
                                    }
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                } else {
                                    Button {
                                        Task {
                                            let sucesso = await viewModel.ocuparPonto(ponto.id)
                                            if sucesso {
                                                mostrarPopupSucesso = true
                                            } else {
                                                mostrarPopupErro = true
                                            }
                                        }
                                    } label: {
                                        if viewModel.carregando {
                                            ProgressView()
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                        } else {
                                            Text("Ocupar ponto")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                        }
                                    }
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Spacer().frame(height: 80)
                        }
                        .padding()
                    }
                    
                    Button {
                        onRouteRequested?()
                    } label: {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                .navigationTitle(ponto.nome)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            mostrarTelaEditar = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
                
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
        .alert("Sucesso", isPresented: $mostrarPopupSucesso) {
            Button("OK") { }
        } message: {
            Text(viewModel.mensagemAcao ?? "Ação realizada com sucesso.")
        }
        .alert("Erro", isPresented: $mostrarPopupErro) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.erro ?? "Ocorreu um erro.")
        }
        .sheet(isPresented: $mostrarTelaEditar) {
            if let ponto = viewModel.pontoSelecionado {
                EditarPontoView(ponto: ponto) {
                    await viewModel.carregarPontoPorId(ponto.id)
                    await viewModel.carregarPontos()
                }
            }
        }
    }
    
    private func blocoTitulo(_ titulo: String) -> some View {
        Text(titulo)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    private func statusVisual(_ ponto: PontoRecarga) -> String {
        if ponto.status.lowercased() == "manutencao" {
            return "Em manutenção"
        }
        if ponto.ocupado == true {
            return "Ocupado"
        }
        return "Disponível"
    }
    
    private func corStatusVisual(_ ponto: PontoRecarga) -> Color {
        if ponto.status.lowercased() == "manutencao" {
            return .orange
        }
        if ponto.ocupado == true {
            return .red
        }
        return .green
    }
}
