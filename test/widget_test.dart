import 'package:flutter_test/flutter_test.dart';

import 'package:cutme/main.dart';

void main() {
  testWidgets('RolePage muncul dengan judul CutMe', (WidgetTester tester) async {
    await tester.pumpWidget(const CutMeApp());

    expect(find.text('CutMe'), findsOneWidget);
    expect(find.text('Masuk sebagai'), findsOneWidget);

    expect(find.text('Pelanggan'), findsOneWidget);
    expect(find.text('Kapster'), findsOneWidget);
    expect(find.text('Admin / Kasir'), findsOneWidget);
  });
}