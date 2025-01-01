import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vigenesia_app/views/login/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: MyApp()));
}

const constServerApi = "http://192.168.1.9:8080/api";

String getApiRoute(route) {
  return '$constServerApi/$route';
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      title: 'VigenSia',
      home: LoginScreen(),
    );
  }
}
