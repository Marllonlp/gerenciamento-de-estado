# Calculadora Flutter

Aplicação para praticar gerenciamento de estado com `StatefulWidget`. A tela recebe dois números e calcula adição, subtração, multiplicação ou divisão.

## Estrutura

- `lib/main.dart`: inicia a aplicação.
- `lib/app.dart`: configura o `MaterialApp` e o tema.
- `lib/calculator/calculator_page.dart`: interface e estado do `StatefulWidget`.
- `lib/calculator/calculator_logic.dart`: operações, validação e formatação dos números.

## Como executar

Com o Flutter instalado, na raiz do projeto:

```bash
flutter pub get
flutter run
```

Para abrir no navegador, use `flutter run -d chrome`.

## Como usar

1. Digite o primeiro e o segundo número. Use vírgula ou ponto para decimais.
2. Toque em uma das quatro operações para ver a expressão e o resultado.
3. Toque em **Limpar** para reiniciar os campos e o resultado.

A aplicação avisa quando algum valor é inválido ou quando há tentativa de divisão por zero. O estado exibido é atualizado com `setState`; os controladores dos campos são descartados em `dispose`.

## Verificação

```bash
flutter analyze
flutter test
flutter build web
```
