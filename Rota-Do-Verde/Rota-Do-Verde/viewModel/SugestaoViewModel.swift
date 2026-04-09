import Foundation
import Combine

@MainActor
final class SugestaoViewModel: ObservableObject {
    @Published var carregando = false
    @Published var mensagemSucesso: String?
    @Published var erro: String?
    
    func enviarSugestao(
        pontoId: String,
        campoSugerido: String,
        valorSugerido: String,
        descricao: String
    ) async {
        carregando = true
        erro = nil
        mensagemSucesso = nil
        
        let request = CriarSugestaoCorrecaoRequest(
            pontoId: pontoId,
            campoSugerido: campoSugerido,
            valorSugerido: valorSugerido,
            descricao: descricao
        )
        
        do {
            let resposta = try await APIService.shared.enviarSugestaoCorrecao(request)
            mensagemSucesso = resposta.mensagem
        } catch {
            erro = error.localizedDescription
        }
        
        carregando = false
    }
}
