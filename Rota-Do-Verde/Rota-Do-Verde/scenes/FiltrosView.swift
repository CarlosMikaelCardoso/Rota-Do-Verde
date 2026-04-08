import SwiftUI

struct FiltrosView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PontosViewModel
    
    // Estados locais para guardar a seleção antes de aplicar
    @State private var status: String = ""
    @State private var conector: String = ""
    @State private var potenciaMin: Int = 0
    @State private var servico: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Status") {
                    Picker("Status", selection: $status) {
                        Text("Todos").tag("")
                        Text("Funcionando").tag("funcionando")
                        Text("Em Manutenção").tag("manutencao")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Tipo de Conector") {
                    Picker("Conector", selection: $conector) {
                        Text("Todos").tag("")
                        Text("Tipo 2").tag("Tipo 2")
                        Text("CCS2").tag("CCS2")
                        Text("CHAdeMO").tag("CHAdeMO")
                    }
                }
                
                Section("Potência Mínima") {
                    Picker("Potência", selection: $potenciaMin) {
                        Text("Qualquer potência").tag(0)
                        Text("22 kW").tag(22)
                        Text("50 kW").tag(50)
                        Text("60 kW").tag(60)
                        Text("150 kW").tag(150)
                    }
                }
                
                Section("Serviços Disponíveis") {
                    Picker("Serviço", selection: $servico) {
                        Text("Todos").tag("")
                        Text("Wi-Fi").tag("wifi")
                        Text("Banheiro").tag("banheiro")
                        Text("Estacionamento").tag("estacionamento")
                        Text("Loja").tag("loja")
                        Text("Conveniência").tag("conveniencia")
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Limpar") {
                        // Limpa os estados e busca todos os pontos novamente
                        status = ""
                        conector = ""
                        potenciaMin = 0
                        servico = ""
                        Task {
                            await viewModel.carregarPontos()
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Aplicar") {
                        Task {
                            await viewModel.filtrarPontos(
                                conector: conector.isEmpty ? nil : conector,
                                potenciaMin: potenciaMin == 0 ? nil : potenciaMin,
                                status: status.isEmpty ? nil : status,
                                servico: servico.isEmpty ? nil : servico
                            )
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
