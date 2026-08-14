import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:steelbuildingtablet/app/theme/app_colors.dart';
import 'package:steelbuildingtablet/features/auth/bindings/login_binding.dart';
import 'package:steelbuildingtablet/features/auth/views/login_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LoginView shows Sign In card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1194, 834));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        initialBinding: LoginBinding(),
        home: const LoginView(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Construction App'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
