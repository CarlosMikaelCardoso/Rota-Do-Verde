import Foundation
import Combine

@MainActor
final class VeiculosViewModel: ObservableObject {
    @Published var veiculos: [Veiculo] = []
    @Published var veiculoSelecionado: Veiculo?
    @Published var carregando = false
    @Published var erro: String?
    
    func carregarVeiculos() async {
        carregando = true
        erro = nil
        
        do {
            veiculos = try await APIService.shared.buscarVeiculos()
        } catch {
            erro = error.localizedDescription
        }
        
        carregando = false
    }
    
    func selecionarVeiculo(_ veiculo: Veiculo) {
        veiculoSelecionado = veiculo
    }
    
    func limparSelecao() {
        veiculoSelecionado = nil
    }
}
