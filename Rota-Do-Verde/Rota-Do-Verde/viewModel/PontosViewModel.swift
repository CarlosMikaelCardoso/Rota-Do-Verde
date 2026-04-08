import Foundation
import Combine

@MainActor
final class PontosViewModel: ObservableObject {
    @Published var pontos: [PontoRecarga] = []
    @Published var pontoSelecionado: PontoRecarga?
    @Published var carregando = false
    @Published var erro: String?
    @Published var mensagemAcao: String?
    
    func carregarPontos() async {
        carregando = true
        erro = nil
        
        do {
            pontos = try await APIService.shared.buscarPontos()
        } catch {
            erro = error.localizedDescription
        }
        
        carregando = false
    }
    
    func carregarPontoPorId(_ id: String) async {
        carregando = true
        erro = nil
        
        do {
            pontoSelecionado = try await APIService.shared.buscarPontoPorId(id)
        } catch {
            erro = error.localizedDescription
        }
        
        carregando = false
    }
    
    func filtrarPontos(
        conector: String? = nil,
        potenciaMin: Int? = nil,
        status: String? = nil,
        servico: String? = nil
    ) async {
        carregando = true
        erro = nil
        
        do {
            pontos = try await APIService.shared.buscarPontosFiltrados(
                conector: conector,
                potenciaMin: potenciaMin,
                status: status,
                servico: servico
            )
        } catch {
            erro = error.localizedDescription
        }
        
        carregando = false
    }
    
    func ocuparPonto(_ id: String) async -> Bool {
        carregando = true
        erro = nil
        mensagemAcao = nil
        
        do {
            let resposta = try await APIService.shared.ocuparPonto(id: id)
            mensagemAcao = resposta.mensagem
            pontoSelecionado = try await APIService.shared.buscarPontoPorId(id)
            carregando = false
            return true
        } catch {
            erro = error.localizedDescription
            carregando = false
            return false
        }
    }
    
    func desocuparPonto(_ id: String) async -> Bool {
        carregando = true
        erro = nil
        mensagemAcao = nil
        
        do {
            let resposta = try await APIService.shared.desocuparPonto(id: id)
            mensagemAcao = resposta.mensagem
            pontoSelecionado = try await APIService.shared.buscarPontoPorId(id)
            carregando = false
            return true
        } catch {
            erro = error.localizedDescription
            carregando = false
            return false
        }
    }
    
    func limparPontoSelecionado() {
        pontoSelecionado = nil
    }
}
