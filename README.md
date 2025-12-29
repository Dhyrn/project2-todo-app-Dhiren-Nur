# project2

1. Project Overview

App name: TaskFlow
Tagline: Organiza tarefas, projetos e tempo num só lugar.

TaskFlow é uma aplicação móvel desenvolvida em Flutter para ajudar utilizadores a gerir tarefas pessoais e projetos de forma simples, mas poderosa. A app permite criar tarefas com prioridades, datas limite, subtarefas e anexos, agrupando-as por projetos para manter o foco em diferentes áreas da vida (trabalho, estudos, pessoal, etc.).
Um dos diferenciais é a integração com localização e condições meteorológicas: o utilizador pode associar uma tarefa a um local e ativar lembretes por proximidade, bem como marcar tarefas de exterior para receber sugestões com base na temperatura atual. Isto torna o planeamento mais inteligente e contextual.
TaskFlow suporta autenticação com email/password e Google, sincronização em tempo real com Firebase Firestore e armazenamento de ficheiros no Firebase Storage, garantindo que os dados estão sempre disponíveis em todos os dispositivos do utilizador.
Além disso, o sistema de subtarefas e anexos facilita partir tarefas grandes em partes menores, anexar imagens ou documentos de apoio e acompanhar o progresso de forma visual. A interface foi pensada para ser limpa, moderna e intuitiva, com cores a indicar prioridades e estados.
O objetivo principal do projeto é demonstrar uma aplicação Flutter completa, com integração de vários serviços Firebase, APIs externas e recursos nativos, aplicando boas práticas de arquitetura, gestão de estado e experiência de utilizador.

Demo video:
[INSERIR LINK DO VÍDEO (YouTube / Loom / etc.)]

Screenshots ():

Login e registo de utilizador
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 38 38" src="https://github.com/user-attachments/assets/b63192ed-1848-4b1b-9b2a-1cd9fbd4387b" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 38 46" src="https://github.com/user-attachments/assets/1f47e81e-eddd-4332-a5ba-df54fa98de79" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 00" src="https://github.com/user-attachments/assets/373e8792-9edc-4806-903c-c556b44a9029" />


Lista de tarefas com filtro e pesquisa
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 10" src="https://github.com/user-attachments/assets/88085a9b-9c00-41e6-b24f-77952ef4bf7b" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 19" src="https://github.com/user-attachments/assets/61e8bc2c-945d-4ff9-a3fe-e9a089ca2f02" />

Criar nova tarefa
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 33" src="https://github.com/user-attachments/assets/3f591fa1-c663-4fff-8ce2-ef55c93b10b3" />


Ecrã de detalhe da tarefa (subtarefas, anexos, localização, tempo, collaboradores)

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 39" src="https://github.com/user-attachments/assets/22f6e7e9-a4dd-4b6f-ad22-43b952bf58da" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 45" src="https://github.com/user-attachments/assets/013a4a94-5110-413b-bc90-33b22416ec6a" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 51" src="https://github.com/user-attachments/assets/0f7fc48a-7eb7-4164-963f-24d7c6ee0dac" />


Ecrã de projetos
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 39 57" src="https://github.com/user-attachments/assets/dc02a634-bf4d-4409-887b-1fb2044eaaa7" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 40 03" src="https://github.com/user-attachments/assets/a870d47c-1d19-43ad-9c64-6e2b31dc08a7" />

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 40 08" src="https://github.com/user-attachments/assets/f7824033-3700-47da-8446-b6c8ddecdb48" />


Ecrã Tarefas de um projeto
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 40 13" src="https://github.com/user-attachments/assets/93ada44c-2535-49d4-b459-68741d324830" />



Ecrã de perfil
<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-12-28 at 23 40 22" src="https://github.com/user-attachments/assets/1b089993-1deb-4122-8700-89b72e9dfa4e" />


2. Features List

Funcionalidades implementadas

Autenticação:

Login e registo com email e password

Login com conta Google

Gestão de sessão (estado autenticado / não autenticado)

Tarefas:

Criar, editar e apagar tarefas

Definir prioridade (Crítico, Alta, Média, Baixa, Deixa pa outro dia)

Definir data de vencimento

Marcar como concluída

Subtarefas com estado próprio

Anexar ficheiros/imagens a tarefas

Projetos:

Criar e apagar projetos

Associar tarefas a projetos

Localização e tempo:

Definir localização atual com GeoPoint

Lembrete por localização (flag para notificar quando perto)

Marcar tarefa como “tarefa exterior”

Sugestões baseadas na temperatura atual (frio, calor, ideal)

Colaboração:

Guardar lista de colaboradores (user IDs) em cada tarefa

UI para partilhar tarefa com outros utilizadores (seleção por dropdown)

Visualizar colaboradores associados a uma tarefa

UX geral:

Lista de tarefas com filtros (prioridade, pesquisa por texto)

Lista de projetos limpa (sem filtros)

Interface responsiva e adaptada para mobile

Recursos nativos utilizados

Acesso à galeria para seleção de imagens (ImagePicker / similar)

Acesso à localização (Geolocator / similar)

Armazenamento de ficheiros no dispositivo (paths temporários)

Integração com serviços Google (Google Sign-In)

Integração com APIs

API de Meteorologia:

Consulta de tempo atual com base em latitude/longitude

Uso da temperatura para gerar mensagens contextuais (frio, quente, ideal)

Serviços Firebase utilizados

Firebase Authentication (email/password, Google)

Cloud Firestore (armazenamento de utilizadores, tarefas, projetos, sharedTasks)

Firebase Storage (anexos / imagens de tarefas, possivelmente foto de perfil)

3. Architecture

Estrutura de pastas (resumo)

lib/

models/

task.dart – modelo de tarefa (prioridade, localização, subtarefas, anexos, colaboradores, flags)

project.dart – modelo de projeto

subtask.dart – modelo de subtarefa

weather.dart – modelo de dados de meteorologia

providers/

auth_provider.dart – estado de autenticação

task_provider.dart – gestão de tarefas (CRUD, anexos, estado concluído)

project_provider.dart – gestão de projetos

weather_provider.dart – gestão de estado do tempo atual

user_provider.dart (se usado) – lista de outros utilizadores para partilha

services/

auth_service.dart – integração com FirebaseAuth e Google Sign-In

user_service.dart – perfis de utilizadores em Firestore, helpers de partilha

firestore_service.dart – acesso a coleções de tarefas e projetos

storage_service.dart – upload/download de anexos em Storage

image_service.dart – seleção de imagens da galeria

weather_service - serviço de estado do tempo através de API

screens/

login_screen.dart, register_screen.dart (separação de autenticação)

list_screen.dart – lista de tarefas com filtro e pesquisa e projetos

detail_screen.dart – detalhe da tarefa (subtarefas, anexos, localização, tempo, colaboradores)

add_edit_screen.dart – criar/editar tarefas

profile_screen - ecrã de perfil do utilizador

register_screen - ecrã de registo de user

login_screen - ecrã de login de user

widgets/

profile_picture_widget - widget para controlar as fotografias de perfil dos users

weather_widget - widget para descobrir o tempo de acordo com a posição do user

firebase_options - ficheiro criado pela firebase

main.dart - estrutura principal

test_image_picker - ecrã de seleção de imagens

Configuração de providers, rotas e tema

Gestão de estado

Padrão utilizado: Provider + ChangeNotifier

Cada domínio principal (auth, tasks, projects, weather) tem um provider próprio, exposto via MultiProvider no main.dart.

A UI consome estes providers via Provider.of<T>(context) ou Consumer<T>.

Padrões de design

Repository/Service pattern:

Providers delegam operações de dados para serviços (FirestoreService, AuthService, UserService, StorageService)

MVVM-like:

Models (Task, Project, etc.), ViewModels (Providers) e Views (Screens) bem separados

Single source of truth:

Firestore como fonte principal, com streams (snapshots) a alimentar os providers.

Diagrama de arquitetura (descrito)

UI (Screens) → Providers (ChangeNotifiers) → Services (Firestore/Auth/Storage/API) → Firebase / APIs externas

Eventos da UI disparam métodos do provider → provider chama service → service atualiza Firestore/Storage → streams atualizam providers → UI reage.

4. Setup Instructions

Pré-requisitos

Flutter SDK: [INSERIR VERSÃO EX: 3.22.x]

Dart SDK compatível (incluído com Flutter)

Conta Firebase com projeto criado

Android Studio / VS Code com extensões Flutter

Dispositivo ou emulador iOS


Como correr a app localmente

bash
flutter pub get
flutter run
Certifica-te que tens um emulador ligado ou dispositivo físico conectado.

Configuração de ambiente

Variáveis sensíveis (API keys de meteorologia, etc.) podem ser colocadas em:

.env (usando package flutter_dotenv), ou

diretamente em constantes no código (exemplo didático, não recomendado para produção).

Atualizar base URL e parâmetros da API de tempo no WeatherProvider / WeatherService.

5. Firebase Configuration

Estrutura de coleções (Firestore)

users/{uid}

uid: string

email: string

displayName: string

photoURL: string

createdAt: Timestamp

Subcoleções:

tasks/{taskId}

title, description, priority, dueDate, isDone

createdAt, updatedAt

subtasks: array de objetos {title, isDone}

location: GeoPoint

locationName: string

attachments: array de strings (URLs)

isOutdoor: bool

locationReminderEnabled: bool

collaborators: array de strings (uids de outros users)

projects/{projectId}

name, color, createdAt

(Opcional) sharedTasks/{taskId}

taskId, ownerId, sharedAt

Organização do Storage

task_attachments/{userId}/{taskId}/{filename}

(Opcional) profile_pictures/{userId}.jpg

Regras de segurança (conceito)

Apenas utilizadores autenticados podem ler/escrever os seus próprios documentos:

match /users/{userId} where request.auth.uid == userId

Tarefas:

Utilizador pode ler/escrever users/{uid}/tasks/* se uid == request.auth.uid.

Opcional: permitir leitura para colaboradores presentes em collaborators.

Storage:

Upload/download de ficheiros apenas se o caminho incluir o userId do utilizador autenticado.

6. API Documentation

APIs utilizadas

API de meteorologia: ex. Open-Meteo (gratuita, sem chave)

Endpoints utilizados (exemplo Open-Meteo)

GET https://api.open-meteo.com/v1/forecast

Parâmetros:

latitude (double)

longitude (double)

current_weather=true

timezone=Europe/Lisbon

language=pt

Exemplo de resposta (resumo simplificado)

json
{
  "latitude": 38.72,
  "longitude": -9.14,
  "timezone": "Europe/Lisbon",
  "current_weather": {
    "temperature": 23.4,
    "windspeed": 10.2,
    "winddirection": 240,
    "weathercode": 1,
    "time": "2025-05-15T14:00"
  }
}
A app lê principalmente o campo current_weather.temperature para gerar a sugestão no DetailScreen.

7. Technologies Used

Flutter

Flutter [INSERIR VERSÃO EX: 3.22.x]

Dart [versão correspondente]

Packages principais (exemplos, ajustar aos teus)

provider – gestão de estado com ChangeNotifier

cloud_firestore – Firebase Firestore

firebase_auth – autenticação

google_sign_in – login Google

firebase_storage – armazenamento de ficheiros

intl – formatação de datas

geolocator – localização

http – chamadas HTTP à API de meteorologia

image_picker – seleção de imagens

Outros conforme pubspec.yaml

Serviços Firebase

Authentication

Cloud Firestore

Cloud Storage

Recursos nativos

Acesso à localização

Acesso à galeria/imagens

Integração com Google Play Services / iOS Services para auth

8. Challenges & Solutions

Desafios técnicos

Sincronizar o estado de tasks entre Firestore e UI em tempo real.

Manter o modelo Task coeso ao adicionar novos campos (subtasks, localização, anexos, colaboradores) sem quebrar dados antigos.

Integrar a API de meteorologia lidando com erros de rede, tempo de resposta e fallback.

Gerir autenticação com múltiplos métodos (email/password e Google) de forma simples.

Lidar com listas aninhadas e streams (tasks, subtasks, projetos, colaboradores) sem blocos de UI confusos.

Soluções adotadas

Uso de Stream do Firestore em FirestoreService + TaskProvider para atualizar automaticamente a lista de tasks.

Implementação de Task.fromFirestore e toFirestore com defaults para campos opcionais e novas propriedades.

Criação de WeatherProvider para centralizar lógica de API meteo e estados (loading, erro, dados).

Encapsular autenticação em AuthService e AuthProvider, permitindo reuso e testes mais simples.

Divisão do UI em widgets menores e uso de Consumer para apenas rebuildar partes necessárias.

Aprendizagens

Integração prática de múltiplos serviços Firebase numa app Flutter real.

Importância de uma arquitetura limpa (separação entre UI, providers e services).

Como trabalhar com dados reativos (streams) e side effects em Flutter.

9. Future Enhancements

Possíveis funcionalidades futuras

Partilha real de tarefas entre utilizadores com permissões (owner vs collaborator) e sincronização de sharedTasks.

Notificações push (Firebase Cloud Messaging) para:

Tarefas com prazo a expirar

Quando alguém partilha uma tarefa contigo

Lembretes por localização reais (geofencing) em background.

Ecrã de calendário para visualizar tarefas por dia/semana/mês.

Modo offline com sincronização posterior.

Tema escuro e personalização de cores.

Limitações conhecidas

Lembrete por localização está marcado no modelo, mas pode não ter lógica de notificação completa em background.

Partilha de tarefas pode estar apenas a nível de UI/modelo, faltando regras avançadas de segurança e permissões.

A API de meteorologia é usada de forma simples, sem cache ou gestão avançada de erros.

10. Credits

APIs

Open-Meteo (ou outra que tenhas usado) – dados de meteorologia.

Assets

Ícones e ilustrações:

Material Icons (incluídos no Flutter)

Outros assets gratuitos (ex.: https://www.flaticon.com/, https://undraw.co/) se usados.

Referências / Tutoriais

Documentação oficial Flutter: https://docs.flutter.dev

Documentação Firebase para Flutter: https://firebase.google.com/docs/flutter

Tutoriais e artigos consultados sobre:

Provider + ChangeNotifier

Integração FirebaseAuth / Firestore / Storage

Uso de Geolocator e APIs HTTP em Flutter
