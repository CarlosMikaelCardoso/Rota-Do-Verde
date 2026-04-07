import Foundation
import Combine

@MainActor
final class CompatibilidadeViewModel: ObservableObject {
    @Published var resposta: CompatibilidadeResponse?
    @Published var pontosCompativeis: [PontoRecarga] = []
    @Published var carregando = false
    @Published var erro: String?
    
    func buscarCompatibilidade(veiculoId: String) async {
        carregando = true
        erro = nil
        
        do {
            let resultado = try await APIService.shared.buscarCompatibilidade(veiculoId: veiculoId)
            resposta = resultado
            pontosCompativeis = resultado.pontosCompativeis
        } catch {
            erro = error.localizedDescription
            resposta = nil
            pontosCompativeis = []
        }
        
        carregando = false
    }
    
    func limpar() {
        resposta = nil
        pontosCompativeis = []
        erro = nil
    }
}
