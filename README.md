# 🎯 Desafio SignWriting — Quiz V ou F

Aplicativo Flutter moderno de Quiz **Verdadeiro ou Falso (V/F)** baseado no material didático e de gincana oficial de **SignWriting (Escrita de Sinais • Curso de Libras)**, com placas táteis animadas, scoreboard persistente e suporte a múltiplos jogadores respondendo simultaneamente na mesma tela.

Projetado especialmente para **Tablets**, **Gincanas**, **Salas de Aula** e **Dispositivos Móveis**.

---

## 🌟 Funcionalidades

- **🎴 Placas Animadas V e F**: Inspiradas fielmente nas *Placas de Resposta* do material oficial:
  - **Verdadeiro (V)**: Animação elástica (*Bounce/Pop*), aura verde esmeralda e celebração.
  - **Falso (F)**: Animação física de vibração (*Shake/Wobble*) e destaque do gabarito correto.
- **📱 Otimizado para Tablet & Gincana**:
  - Escala automática de fontes grandes (34-38pt) para visualização clara à distância.
  - Placas ampliadas (76pt) com alta precisão de toque.
- **⚡ Multijogador Simultâneo na Mesma Tela (2 a 4 Jogadores)**:
  - Cada participante tem seu próprio quadrante e placas na tela.
  - Respostas travadas em segredo (`🔒 Bloqueada`) para evitar cópia entre jogadores.
  - Revelação síncrona com cálculo de bônus por velocidade e acerto!
- **🏫 Modo Apresentador / Turma**:
  - Perfeito para projetores ou sala de aula, permitindo à turma levantar as placas físicas enquanto o condutor registra os pontos das equipes.
- **🏆 Scoreboard Completo (Placar Persistente)**:
  - Aba de **Recordes Solo** (Hall da Fama com acurácia, data e pontos).
  - Aba de **Histórico Multiplayer** (registro de partidas e vencedores).
- **⚙️ Perguntas 100% Configuráveis via JSON**:
  - Importação de JSON personalizado com validação sintática em tempo real.
  - Exportação de JSON com um clique para a área de transferência.
  - Editor manual para adicionar, editar e remover perguntas.
  - Botão de restauração rápida para o baralho oficial do PDF.
- **🎨 Design Nativo Android Moderno**:
  - Material 3 (Material You) com suporte a **Modo Claro** e **Modo Escuro**.

---

## 📖 Perguntas Oficiais do Baralho

As afirmações e justificativas foram extraídas do material oficial `jogos_signwriting_coloridos_com_placas_VF (1).pdf`:

1. **Valerie Sutton começou criando um sistema para registrar movimentos de dança.** → **V** *(DanceWriting em 1966)*
2. **A Escrita de Sinais foi criada originalmente no Brasil.** → **F** *(Dinamarca em 1974)*
3. **O SignWriting começou a ser desenvolvido para registrar línguas de sinais em 1974.** → **V**
4. **Valerie Sutton foi a criadora da Libras.** → **F** *(Criou o sistema SignWriting, não a Libras)*
5. **A Escrita de Sinais representa somente os movimentos das mãos.** → **F** *(Registra orientação, localização e expressões não manuais)*
6. **Expressões faciais e outros elementos do corpo também podem ser representados.** → **V**
7. **A Escrita de Sinais foi introduzida no Brasil em 1996.** → **V**
8. **O SignWriting permite registrar visualmente línguas de sinais.** → **V**
*(Inclui também cartas conceituais do Jogo da Memória como termos bônus)*

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.x+
- Dispositivo Android, Tablet, ou Navegador Chrome

```bash
# Obter dependências
flutter pub get

# Executar os testes
flutter test

# Rodar no dispositivo conectado
flutter run

# Rodar no Chrome (Web)
flutter run -d chrome
```

---

## 🤖 CI/CD & Geração Automática de APK por Tag

O projeto possui integração contínua (GitHub Actions) configurada para gerar o APK automaticamente e criar uma nova Release no GitHub sempre que uma tag de versão for publicada:

```bash
# Criar uma nova tag de versão (ex: v1.0.0)
git tag v1.0.0

# Enviar a tag para o GitHub
git push origin v1.0.0
```

Assim que a tag for enviada:
1. O GitHub Actions iniciará o workflow [`.github/workflows/release.yml`](.github/workflows/release.yml).
2. O código será analisado e testado (`flutter analyze` e `flutter test`).
3. O APK de release será compilado (`flutter build apk --release`).
4. Uma nova **GitHub Release** será publicada automaticamente contendo o arquivo `festival-quiz-v1.0.0.apk` pronto para download e instalação direta em tablets ou smartphones Android.

---

## 📜 Licença

Distribuído sob a licença **GNU General Public License v3.0 (GPL-3.0)**. Consulte o arquivo [LICENSE](LICENSE) para obter mais informações.
