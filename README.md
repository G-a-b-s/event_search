# 📱 EventSearch


## 🚀 Como rodar o projeto em outra máquina

Siga os passos abaixo para configurar e executar este projeto Flutter com Firebase em um novo ambiente.

### ✅ Pré-requisitos

Certifique-se de ter instalado:

- Flutter SDK: https://flutter.dev/docs/get-started/install
- Firebase CLI: https://firebase.google.com/docs/cli
- FlutterFire CLI: https://firebase.flutter.dev/docs/cli/
- Um editor como o VS Code ou Android Studio
- Emulador Android ou navegador Chrome (caso for rodar como app web)

### 📥 1. Clonar o repositório

Abra o terminal e digite:

```bash
git clone https://github.com/seu-usuario/event_search.git
cd event_search
```

### 📦 2. Instalar as dependências do projeto

```bash
flutter pub get
```

### 🔥 3. Configurar o Firebase

Se ainda não tiver o FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Configure a conexão com seu projeto Firebase (gera o `firebase_options.dart` automaticamente):

```bash
flutterfire configure
```

- Selecione seu projeto Firebase existente (não crie um novo).
- Marque as plataformas que você usará (ex: `android`, `web`, etc).
- *Normalmente vai marcar somente `android`, `web`. Para desmarcar so ir na setinha para baixo e para cima e clicar espaco para desmarcar.*
- O arquivo `firebase_options.dart` será criado dentro da pasta `lib/`.

> **Importante:** Esse arquivo **não é versionado no Git** (está no `.gitignore`), então será necessário rodar o comando acima sempre que clonar o projeto.

### ▶️ 4. Rodar o projeto

#### Para rodar no navegador:

```bash
flutter run -d chrome
```

#### Para rodar no emulador Android:

```bash
flutter run -d emulator-5554
```

> Verifique os dispositivos disponíveis com:
> ```bash
> flutter devices
> ```

### 🛠️ Tecnologias usadas

- Flutter
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- FlutterFire CLI

### ℹ️ Observações

- As senhas dos usuários são gerenciadas pelo Firebase Authentication e **não são salvas no Firestore**.
- Dados como `nome`, `email` e `dataCadastro` são salvos na coleção `cadastro` do Firestore.
- A aplicação está com `.gitignore` configurado para ignorar arquivos sensíveis e cache.

### 📄 Licença

Este projeto é livre para uso e modificação. Sinta-se à vontade para contribuir!

---

Desenvolvido com 💙 usando Flutter + Firebase
