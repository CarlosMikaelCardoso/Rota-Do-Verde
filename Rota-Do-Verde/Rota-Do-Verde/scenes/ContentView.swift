import SwiftUI
import MapKit

// 1. Modelo de Dados com Identifiable
struct location: Hashable, Identifiable {
    let id = UUID() // Adicionado para facilitar o uso em Sheets e Lists
    let nome: String
    let foto: String
    let descricao: String
    let latitude: Double
    let longitude: Double
    
    var coordenada: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct ContentView: View {
    @State private var selectedLocation: location?
    @State private var locationForNavigation: location?
    
    // Posição inicial da câmera
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -1.4746, longitude: -48.4534),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    @State var arrayLocation: [location] = [
        location(
            nome: "Dirtmouth",
            foto: "https://i.pinimg.com/736x/f6/cb/98/f6cb98187528a438388210f07a303f0c.jpg",
            descricao: "Conhecida como a Cidade Desvanecida, Dirtmouth é o último vestígio de civilização na superfície de Hallownest, servindo como o portão de entrada para as profundezas do reino. O vento sopra de forma melancólica através de suas ruas desertas, carregando o eco de uma era de glória que há muito se perdeu no tempo. Poucos residentes permanecem, sendo o Velho Ancião o mais notável, observando silenciosamente os viajantes que chegam em busca de segredos. O local exala uma atmosfera de solidão e paz fúnebre, onde o brilho fraco das lanternas tenta afastar a escuridão persistente que sobe dos poços. É aqui que os guerreiros descansam antes de enfrentar os perigos das encruzilhadas, buscando um momento de conforto antes do mergulho inevitável no esquecimento. A arquitetura é simples e desgastada, refletindo o cansaço de um mundo que parou de girar, enquanto a poeira se acumula sobre as memórias daqueles que nunca retornaram de suas jornadas subterrâneas.",
            latitude: -1.4746529,
            longitude: -48.4534834
        ),
        
        location(
            nome: "Black Egg Temple",
            foto:"https://i.ytimg.com/vi/LDTJf4E3dFU/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLAMVk-is5VJAFVDbcQG9MakpNnkbw",
            descricao: "O Templo do Ovo Negro surge como uma estrutura monumental e opressiva, construída com o propósito único de selar uma força antiga que ameaça consumir toda a existência. Suas paredes de pedra negra são gravadas com runas poderosas, e a entrada é guardada por selos mágicos que apenas os mais determinados podem romper. No centro deste local sagrado e terrível, repousa o receptáculo que carrega o peso de um reino inteiro sobre seus ombros, envolto em correntes que ecoam o sacrifício supremo. A atmosfera dentro do templo é densa e carregada de uma energia estática, onde o silêncio é interrompido apenas pelo pulsar rítmico de uma infecção que luta para escapar de sua prisão. É um lugar de reverência e medo, onde o destino de Hallownest foi decidido e onde o fim de todas as coisas aguarda pacientemente por um novo desfecho. Os cavaleiros que se aproximam sentem o frio da morte emanando do núcleo, lembrando-os de que a salvação muitas vezes exige um preço que ninguém está disposto a pagar.",
            latitude: -1.4744774,
            longitude: -48.4516047
        ),
        
        location(
            nome: "Forgotten Crossroads",
            foto: "https://i.pinimg.com/736x/c1/82/c3/c182c38cb583bb49dd79fe611d640e4e.jpg",
            descricao: "As Encruzilhadas Esquecidas já foram as artérias pulsantes do comércio e transporte de Hallownest, repletas de besouros e viajantes que seguiam para todas as direções do reino. Hoje, este labirinto de túneis está infestado por criaturas que perderam a mente para uma praga silenciosa, transformando caminhos familiares em armadilhas mortais e sombrias. O som de passos metálicos ecoa pelas cavernas úmidas, onde a luz de cristais naturais brilha fracamente contra as paredes de pedra bruta. Antigas estações de transporte permanecem como monumentos silenciosos ao progresso, agora cobertas por fungos e teias que escondem segredos de civilizações passadas. Existe uma sensação constante de perigo iminente em cada curva, pois a infecção começou a borbulhar através das rachaduras, transformando o que era funcional em algo grotesco e hostil. Apesar da decadência, o local mantém uma beleza trágica, revelando a escala do que o reino um dia foi antes de cair em ruína total e ser abandonado pela luz do sol.",
            latitude: 48.8584,
            longitude: 2.2945
        ),
        
        location(
            nome: "Greenpath",
            foto: "https://i.pinimg.com/736x/dd/3a/0f/dd3a0f7e87962faee10cd544d7bf674f.jpg",
            descricao: "Caminho Verde é um santuário exuberante de vida vegetal que floresce de forma indomável nas profundezas, alimentado por rios de ácido que serpenteiam por entre as rochas. O ar é úmido e perfumado com o cheiro de musgo fresco, contrastando drasticamente com a secura das encruzilhadas vizinhas. Criaturas camufladas espreitam entre as folhas gigantes, protegendo seu território com uma ferocidade silenciosa e movimentos ágeis que desafiam a visão dos incautos. Estruturas de pedra cobertas por trepadeiras indicam que uma sociedade mística outrora chamou este lugar de lar, adorando a natureza e as formas de vida que crescem sob a terra. O som constante de água corrente cria uma melodia relaxante, mas enganosa, pois qualquer passo em falso pode levar a uma queda fatal nas piscinas corrosivas que sustentam esse ecossistema. É um lugar de beleza vibrante e letal, onde a luta pela sobrevivência é travada através da elegância e da velocidade, sob a guarda constante de guerreiros mascarados que não toleram invasores.",
            latitude: 35.6895,
            longitude: 139.6917
        ),
        
        location(
            nome: "City of Tears",
            foto:"https://static0.srcdn.com/wordpress/wp-content/uploads/2021/05/Featured-Image-Hollow-Knight-Statue-Cropped.jpg?w=1200&h=675&fit=crop",
            descricao: "A Cidade das Lágrimas é a capital eterna do reino, uma maravilha arquitetônica de torres altas e vitrais magníficos que se estende sob um teto de pedra porosa. A chuva cai incessantemente das águas do Lago Azul acima, criando um som perene de gotas batendo contra o pavimento polido e as janelas de cristal. Suas ruas largas e elevadores majestosos contam a história de uma elite que vivia em luxo absoluto, cercada por guardas em armaduras douradas e fontes que nunca paravam de jorrar. Agora, as mansões estão vazias e os grandes salões são habitados apenas pelas sombras de uma nobreza que se recusa a aceitar o seu fim, mantendo rituais vazios em meio ao mofo. A luz azulada que emana das lanternas de alma reflete nas poças de água, dando à cidade um brilho melancólico e sonhador que encanta e entristece ao mesmo tempo. É o coração de Hallownest, onde a cultura e a tragédia se fundem em um monumento de pedra que recusa desaparecer, mesmo que todos os seus cidadãos já tenham perdido o juízo.",
            latitude: 51.5074,
            longitude: -0.1278
        ),
        
        location(
            nome: "Crystal Peak",
            foto: "https://i.pinimg.com/736x/9c/09/31/9c0931714823cf3d5e6c65a34203799f.jpg",
            descricao: "O Pico de Cristal é uma montanha de minério brilhante que se eleva acima das nuvens de poeira do reino, emitindo um zumbido constante de energia bruta. As minas são repletas de cristais rosados que crescem nas paredes como tumores radiantes, possuindo uma dureza capaz de cortar as armaduras mais resistentes. Máquinas antigas ainda operam sozinhas, movidas por mecanismos de mola e pressão que Rangem e estalam no vácuo das cavernas profundas. Os mineiros que aqui trabalhavam foram consumidos pela mesma luz que tentavam extrair, transformando-se em cascas que atacam qualquer um que interrompa seu ciclo eterno de escavação. A luz refletida nos cristais pode cegar os despreparados, criando um jogo de sombras e reflexos que torna a navegação extremamente perigosa entre as engrenagens gigantes. É um lugar de progresso industrial interrompido pela catástrofe, onde o brilho da riqueza mineral se tornou a prisão daqueles que ousaram cobiçar o poder escondido dentro do coração da montanha.",
            latitude: -33.8688,
            longitude: 151.2093
        ),
        
        location(
            nome: "Deepnest",
            foto: "https://preview.redd.it/92434hfqr1nb1.png?auto=webp&s=aa18af86774c39726efd6dd625f6e1a64dca1ce8",
            descricao: "Ninho Profundo é um labirinto claustrofóbico de túneis escuros e passagens estreitas, onde o som de patas rastejantes é a única constante no silêncio opressor. Diferente do restante de Hallownest, este território nunca foi totalmente subjugado pelo Rei Pálido, mantendo suas tradições tribais e uma hostilidade feroz contra estranhos. Teias de aranha gigantescas cobrem o teto e o chão, ocultando armadilhas naturais e criaturas que podem mudar de forma para enganar suas presas. A atmosfera é carregada de um pavor primordial, onde a escuridão parece ter vida própria e as paredes parecem se fechar sobre aqueles que ousam explorar suas profundezas. Cada sombra esconde um predador e cada fenda na rocha pode levar a um covil repleto de horrores que desafiam a sanidade. É um lugar de sobrevivência brutal, onde apenas os mais astutos e rápidos conseguem evitar se tornar mais uma carcaça pendurada nos tetos de seda, servindo de alimento para a ninhada que nunca para de crescer sob o solo.",
            latitude: 40.7128,
            longitude: -74.0060
        ),
        
        location(
            nome: "Kingdom's Edge",
            foto: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxjdqJhUUfDcb7DmYq8f14rY8boBIS5k1Qmw&s",
            descricao: "A Borda do Reino situa-se nos limites extremos de Hallownest, onde as falésias descem para um abismo sem fim e o ar é preenchido por cinzas brancas constantes. Essas cinzas, que caem como neve silenciosa, são na verdade restos de um ser gigantesco que morreu há eras, cobrindo o terreno com uma camada pálida e poeirenta. O local é habitado por guerreiros nômades e feras que não conhecem a lei do rei, vivendo em um estado de selvageria constante entre os picos afiados de rocha. Grandes estruturas ósseas emergem do chão, servindo como abrigo e arena para aqueles que buscam provar seu valor através da força bruta. A sensação de estar no fim do mundo é absoluta, com o vento uivando através das cavernas abertas e a vista para o vazio absoluto que circunda o reino. É um lugar de revelações e testes de coragem, onde o passado de Hallownest se encontra com o nada, e onde os segredos mais antigos estão enterrados sob camadas de poeira e ossos de gigantes esquecidos.",
            latitude: -22.9068,
            longitude: -43.1729
        ),
        
        location(
            nome: "Ancient Basin",
            foto: "https://i.pinimg.com/736x/bb/69/d5/bb69d50727d83458e009e7e12818bade.jpg",
            descricao: "A Bacia Antiga é uma das áreas mais profundas e desoladas de Hallownest, um lugar onde o tempo parece ter parado em uma estagnação poeirenta e cinzenta. O solo é coberto por uma areia fina que silencia os passos dos viajantes, criando uma atmosfera de isolamento absoluto longe de qualquer forma de luz natural. Ruínas de infraestruturas reais indicam que este local já teve uma importância estratégica imensa, servindo como base para projetos secretos que o Rei Pálido preferiria manter ocultos. Criaturas sem mente vagam pela bacia, alimentando-se de resíduos de alma e sombras que parecem brotar diretamente do chão. Não há música ou vento aqui, apenas o eco distante de gotas de água e o sentimento de que algo vasto e perigoso dorme logo abaixo da superfície. É o limiar do Abismo, um ponto de não retorno onde a história de Hallownest se torna sombria e as respostas para a origem da infecção começam a aparecer em meio à poeira e ao silêncio eterno das profundezas.",
            latitude: 30.0444,
            longitude: 31.2357
        ),
        
        location(
            nome: "Fog Canyon",
            foto: "https://i.ytimg.com/vi/u1PAsgjD3fc/maxresdefault.jpg",
            descricao: "Cânion da Névoa é uma fenda profunda preenchida por névoas densas e borbulhantes que emitem um brilho fosforescente suave e hipnotizante. Estruturas orgânicas que lembram bolhas gigantes flutuam no ar, servindo de habitat para águas-vivas elétricas que defendem seu território com explosões devastadoras. O local é imbuído de uma energia mágica estranha, possivelmente ligada aos experimentos realizados nos arquivos que se escondem em seu interior. A visibilidade é baixa, forçando os exploradores a se moverem com cautela extrema para não colidirem com os ovos explosivos que pendem do teto. O som ambiente é um murmúrio de gases escapando e eletricidade estática, criando uma experiência sensorial única e alienígena em comparação com o resto do reino. Poucos se aventuram aqui sem um propósito claro, pois a beleza das luzes flutuantes esconde uma reatividade química que pode transformar uma caminhada tranquila em uma sucessão de detonações em cadeia, destruindo tudo ao redor.",
            latitude: 55.7558,
            longitude: 37.6173
        ),
        
        location(
            nome: "The Hive",
            foto: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4zowiOxwg69GEwC3hv17t-R4wJ8cI486Oug&s",
            descricao: "A Colmeia é uma fortaleza dourada e secreta escondida dentro das paredes da borda do reino, onde o aroma de mel doce impregna cada centímetro cúbico de ar. Suas paredes são feitas de hexágonos perfeitos esculpidos em âmbar e cera, refletindo uma ordem social rígida e uma devoção absoluta à sua rainha. As abelhas que habitam este local são ferozes e territoriais, atacando com precisão militar qualquer um que ouse ameaçar o estoque de mel ou a tranquilidade da colônia. O brilho dourado que emana das paredes cria uma atmosfera de riqueza e calor, contrastando com o frio das cinzas que caem logo do lado de fora. Apesar de sua beleza estonteante, a colmeia é um lugar de isolamento autoimposto, onde o tempo é medido pelo trabalho incessante e pela produção de uma doçura que nunca será compartilhada com o resto de Hallownest. É um monumento à preservação de uma linhagem, protegida por guerreiros que preferem a morte à intrusão, mantendo seu modo de vida imune às mudanças que devastaram o mundo exterior.",
            latitude: -34.6037,
            longitude: -58.3816
        ),
        
        location(
            nome: "Colosseum of Fools",
            foto:"https://i.ytimg.com/vi/_2nj5bGbzRk/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLD4-xAYjQgvjFjpfFGn7HboJBYBbA",
            descricao: "O Coliseu dos Tolos é uma arena de combate brutal esculpida dentro da carcaça de um ser colossal, onde a glória é comprada com sangue e o entretenimento é a única lei. Guerreiros de todos os cantos do mundo viajam até aqui para testar suas habilidades em desafios sádicos, enfrentando ondas de feras e outros combatentes sob os gritos de uma multidão invisível. O chão da arena está perpetuamente manchado, e as paredes são decoradas com os troféus daqueles que falharam em suas buscas por reconhecimento. Não há honra ou misericórdia nos jogos, apenas a busca por uma recompensa que muitas vezes se revela tão vazia quanto as promessas do coliseu. Aqueles que assistem das sombras riem da tolice dos que arriscam suas vidas por um título sem valor, enquanto a música de batalha ecoa pelos corredores repletos de competidores ansiosos. É um lugar de energia frenética e violência artística, onde a única coisa que importa é quanto tempo você consegue permanecer de pé antes que a próxima lâmina encontre o seu caminho através da sua armadura.",
            latitude: 41.8902,
            longitude: 12.4922
        )
    ]
    

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $position, selection: $selectedLocation) {
                    ForEach(arrayLocation) { loc in
                        Marker(loc.nome, coordinate: loc.coordenada)
                            .tag(loc)
                    }
                }
                .mapStyle(.standard(emphasis: .muted))
                .ignoresSafeArea()
                // Picker flutuando sobre o mapa
                Picker("Selecione um local", selection: $selectedLocation) {
                    Text("📍 Explorar Hallownest").tag(nil as location?)
                    ForEach(arrayLocation) { loc in
                        Text(loc.nome).tag(loc as location?)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }
                .padding(.top, -40) // Ajuste esse valor para o Picker não bater no topo/notch
            }

            .onChange(of: selectedLocation) { _, newLocation in
                if let newLocation = newLocation {
                    // 1. Executa a animação da câmera do mapa
                    withAnimation(.snappy) {
                        position = .region(
                            MKCoordinateRegion(
                                center: newLocation.coordenada,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            )
                        )
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        locationForNavigation = newLocation
                    }
                }
            }
            .navigationDestination(item: $locationForNavigation) { local in
                pontoView(local: local)
            }
        }
    }
}

#Preview {
    ContentView()
}

