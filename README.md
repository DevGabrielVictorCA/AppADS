# 📦 App de Entregas - Documentação Completa

## 🧭 Contexto Geral do Projeto

O projeto é um **aplicativo de entregas** desenvolvido em **Flutter** (com `sqflite_common_ffi`, `provider` e widgets nativos do Flutter), simulando um sistema com **três tipos de usuários**:

1. **Gestor** → administra o sistema, agenda entregas, cadastra entregadores e receptores e acessa relatórios.
2. **Entregador** → visualiza as entregas atribuídas a ele, atualiza o status (“Concluída”, “Pendente” etc.) e pode marcar problemas.
3. **Receptor** → acompanha as entregas destinadas a ele e visualiza o status.

O aplicativo possui **sistema de login e cadastro local**, com dados armazenados em **SQLite**, e o controle de estado feito via **Provider**.

---

## 🎯 Objetivos do Projeto

- Criar um aplicativo funcional de entregas para fins acadêmicos.
- Gerenciar usuários com diferentes perfis e permissões.
- Permitir ao gestor criar entregas e acompanhar entregadores e receptores.
- Registrar e atualizar status das entregas em tempo real (simulado localmente).
- Fornecer uma base para futuras integrações com banco de dados remoto ou funcionalidades avançadas.

---

## 🗂 Escopo do Projeto

- Cadastro e login de **Gestor, Entregador e Receptor**.
- Gestão de entregas (criação, atribuição, atualização de status).
- Controle de visualização de entregas de acordo com o perfil do usuário.
- Relatórios de desempenho (placeholder).
- Persistência local com SQLite.
- Interface responsiva usando Flutter e widgets nativos.

---

## 👥 Stakeholders

- **Gestor:** administrador do sistema, responsável pelo planejamento das entregas.
- **Entregador:** recebe entregas atribuídas, atualiza status e reporta problemas.
- **Receptor:** acompanha suas entregas e verifica status.
- **Professor / Avaliador:** analisa o projeto acadêmico.
- **Aluno (Desenvolvedor):** responsável por implementar, testar e documentar o app.

---

## ⚙ Arquitetura e Estrutura de Arquivos

### 1. `main.dart`
- Ponto de entrada do app.
- Inicializa o banco (`sqflite_common_ffi`) e o `EntregasProvider`.
- Tela inicial: `LoginPage`.

### 2. `login_page.dart`
- Tela de login com **usuário e senha**.
- Redireciona para `WelcomePage` conforme o tipo de usuário.

### 3. `cadastro_page.dart`
- Registro de novos usuários.
- Campos: nome, e-mail, senha e tipo de usuário.
- Salva os dados no SQLite local.

### 4. `welcome_page.dart`
Reúne as telas específicas:

#### 🟩 GestorPage
- Saudação personalizada.
- Menu com **cards**: Entregas, Entregadores, Relatórios, Receptores, Configurações e Sair.

#### 🟦 EntregadorPage
- Mostra entregas atribuídas.
- Permite atualizar o status e marcar problemas.

#### 🟨 ReceptorPage
- Exibe entregas destinadas ao receptor.
- Pode confirmar recebimento.

---

## 📦 Outros Arquivos Importantes

### `entregas_provider.dart`
- Classe `ChangeNotifier` que gerencia a lista de entregas.
- Métodos principais: `adicionarEntrega()`, `atualizarStatus()`, `notificarListeners()`.

### `gestor_entregas.dart`
- Tela para o gestor criar e atribuir novas entregas.

### `entregadores_page.dart`
- Lista entregadores e permite adicionar novos.

### `receptores_page.dart`
- Lista receptores e permite cadastrar novos.

### `relatorios_gestor.dart`
- Placeholder para **relatórios** (entregas concluídas, tempo médio, desempenho).

---

## 🔗 Integrações e Recursos Técnicos

- **Provider:** gerenciamento de estado entre telas.
- **SQLite (sqflite_common_ffi):** persistência local.
- **Login funcional:** redirecionamento conforme o perfil.
- **Controle de acesso:** cada usuário visualiza apenas o que lhe compete.
- **Design Material:** uso de Scaffold, AppBar, Cards e ListView.

---

## 🧠 Resumo Técnico

| Recurso | Descrição |
|----------|------------|
| **Linguagem** | Dart (Flutter) |
| **Gerência de estado** | Provider |
| **Banco de dados** | SQLite (`sqflite_common_ffi`) |
| **Navegação** | `Navigator.push` / `pop` / `MaterialPageRoute` |
| **Perfis de usuários** | Gestor, Entregador, Receptor |
| **Plataforma** | Android (APK Release) |

---

## ⚙ Como Executar o Projeto (Código-Fonte)

1. Clonar o repositório:

```bash
git clone https://github.com/DevGabrielVictorCA/AppADS.git
```

2. Abrir no **VS Code** ou **Android Studio**.

3. Instalar dependências:

```bash
flutter pub get
```

4. Executar no emulador ou dispositivo:

```bash
flutter run
```

5. Gerar APK (opcional):

```bash
flutter build apk --release
```
---

## 📲 Instalação
O arquivo de instalação (.apk) está disponível no **link** abaixo
<br>
[Baixar APK - NUMERODERA_app](https://drive.google.com/drive/folders/1GRjiTVj5SeCedAhp7mAcaKxNR0EcGqrh?usp=sharing)


## 📚 Referências e Bibliotecas

* [Flutter](https://flutter.dev/)
* [Provider](https://pub.dev/packages/provider)
* [SQLite / sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)

## 🧩 Observações Finais

Este projeto foi desenvolvido para **fins acadêmicos**, simulando um sistema de entregas com múltiplos perfis de usuários e persistência local.
O layout original deve ser mantido — qualquer modificação deve respeitar as diretrizes de design previamente definidas.