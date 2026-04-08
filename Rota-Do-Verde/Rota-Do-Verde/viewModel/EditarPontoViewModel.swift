import Foundation
import Combine

@MainActor
final class EditarPontoViewModel: ObservableObject {
    @Published var nome = ""
    @Published var descricao = ""
    @Published var status = "funcionando"
    @Published var latitude = ""
    @Published var longitude = ""
    @Published var endereco = ""
    
    @Published var conectorTipo = ""
    @Published var conectorPotencia = ""
    @Published var servicosTexto = ""
    
    @Published var carregando = false
    @Published var erro: String?
    @Published var mensagemSucesso: String?
    
    let pontoId: String
    
    init(ponto: PontoRecarga) {
        self.pontoId = ponto.id
        self.nome = ponto.nome
        self.descricao = ponto.descricao ?? ""
        self.status = ponto.status
        self.latitude = String(ponto.latitude)
        self.longitude = String(ponto.longitude)
        self.endereco = ponto.endereco
        
        if let primeiroConector = ponto.conectores.first {
            self.conectorTipo = primeiroConector.tipo
            self.conectorPotencia = String(primeiroConector.potenciaKW)
        }
        
        self.servicosTexto = ponto.servicos.joined(separator: ", ")
    }
    
    var formularioValido: Bool {
        !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !endereco.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(latitude) != nil &&
        Double(longitude) != nil
    }
    
    func definirCoordenada(latitude: Double, longitude: Double) {
        self.latitude = String(latitude)
        self.longitude = String(longitude)
    }
    
    func salvarEdicao() async -> Bool {
        erro = nil
        mensagemSucesso = nil
        
        guard let latitudeDouble = Double(latitude),
              let longitudeDouble = Double(longitude) else {
            erro = "Latitude ou longitude inválida."
            return false
        }
        
        carregando = true
        
        let conectores: [Conector]?
        if !conectorTipo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let potencia = Int(conectorPotencia) {
            conectores = [
                Conector(tipo: conectorTipo, potenciaKW: potencia)
            ]
        } else {
            conectores = []
        }
        
        let servicos = servicosTexto
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let request = EditarPontoRequest(
            nome: nome,
            descricao: descricao,
            status: status,
            latitude: latitudeDouble,
            longitude: longitudeDouble,
            endereco: endereco,
            conectores: conectores,
            servicos: servicos,
            ativo: nil,
            ocupado: nil,
            ocupadoEm: nil
        )
        
        do {
            let resposta = try await APIService.shared.editarPonto(id: pontoId, body: request)
            mensagemSucesso = resposta.mensagem
            carregando = false
            return true
        } catch {
            erro = error.localizedDescription
            carregando = false
            return false
        }
    }
}
