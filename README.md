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
- Controle de visualização de entregas de acordo com perfil do usuário.
- Relatórios de desempenho (placeholder).
- Persistência local com SQLite para usuários e entregas.
- Interface responsiva usando Flutter e widgets nativos.

---

## 👥 Stakeholders

- **Gestor**: administrador do sistema, responsável pelo planejamento das entregas.
- **Entregador**: recebe entregas atribuídas, atualiza status e reporta problemas.
- **Receptor**: acompanha suas entregas e verifica status.
- **Professor / Avaliador**: analisa a entrega do projeto acadêmico.
- **Equipe de desenvolvimento (aluno)**: responsável por implementar, testar e documentar o app.

---

## ⚙ Arquitetura e Estrutura de Arquivos

### 1. `main.dart`
- Ponto de entrada do app.
- Inicializa banco de dados (`sqflite_common_ffi`) e Provider (`EntregasProvider`).
- Tela inicial: `LoginPage`.

### 2. `login_page.dart`
- Tela de login com campos de **usuário** e **senha**.
- Link para cadastro (`cadastro_page.dart`).
- Após autenticação, redireciona para `WelcomePage` com `nomeDoUsuario` e `tipoUsuario`.

### 3. `cadastro_page.dart`
- Registro de novos usuários.
- Campos: nome, e-mail, senha, tipo de usuário.
- Salva usuário no banco local.

### 4. `welcome_page.dart`
Contém as páginas principais de cada tipo de usuário:

#### 🟩 GestorPage
- Saudação personalizada.
- Menu em **cards**: Entregas, Entregadores, Relatórios, Notificações / Receptores, Configuração e Sair.
- Botões usam **MenuButton customizado**.

#### 🟦 EntregadorPage
- Estatísticas de entregas via `EntregasProvider`.
- Lista entregas do entregador.
- Cada entrega exibe: endereço, status, destinatário, horário e botões “Detalhes”, “Concluir”, “Problemas”.
- Botão “Concluir” atualiza status.
- Logout incluso.

#### 🟨 ReceptorPage
- Exibe apenas entregas destinadas ao receptor.
- Sem botões de atualização de status.
- Pode incluir botão “Confirmar recebimento”.

---

## 📦 Outros Arquivos Importantes

### `entregas_provider.dart`

* `ChangeNotifier` que gerencia a lista de entregas.
* Métodos: `adicionarEntrega()`, `atualizarStatus()`, `notificarListeners()`.
* Usado por gestores e entregadores para atualizar a UI.

### `gestor_entregas.dart`

* Tela para o gestor criar e atribuir entregas.
* Campos: entregador, receptor, endereço, data e hora.
* Salva entrega no `EntregasProvider`.

### `entregadores_page.dart`

* Lista entregadores registrados.
* Botão “Adicionar Entregador” abre formulário simples.

### `receptores_page.dart`

* Lista receptores registrados.
* Cadastro e visualização local.

### `relatorios_gestor.dart`

* Placeholder para **relatórios de desempenho**.
* Métricas previstas: total de entregas, percentual concluídas, tempo médio, entregadores mais ativos.

---

## 🔗 Integração Planejada

* **Provider**: sincroniza dados entre Gestor, Entregador e Receptor.
* **SQLite**: persistência de usuários e entregas.
* **Login funcional**: validação e redirecionamento conforme perfil.
* **Controle de acesso**: cada perfil visualiza apenas o que lhe compete.

---

## 🧠 Resumo Técnico

* **Linguagem:** Dart (Flutter)
* **Gerência de estado:** Provider
* **Banco de dados:** SQLite (`sqflite_common_ffi`)
* **Navegação:** `Navigator.push`, `Navigator.pop`, `MaterialPageRoute`
* **Design:** Scaffold, AppBar, Card, Wrap, ListView.builder
* **Perfis de usuários:** Gestor, Entregador, Receptor

---

## ⚙ Como Executar

1. Clonar o repositório:

```bash
git clone <URL_DO_REPOSITORIO>
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

## 📚 Referências e Bibliotecas

* [Flutter](https://flutter.dev/)
* [Provider](https://pub.dev/packages/provider)
* [SQLite / sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)
