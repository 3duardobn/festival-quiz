import 'package:flutter_test/flutter_test.dart';
import 'package:festival_quiz/main.dart';

void main() {
  testWidgets('Festival Quiz App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FestivalQuizApp(initialDarkMode: false));
    await tester.pumpAndSettle();

    expect(find.text('SignWriting Quiz'), findsOneWidget);
    expect(find.text('Desafio SignWriting'), findsOneWidget);
    expect(find.text('1 Jogador (Modo Solo)'), findsOneWidget);
  });
}
