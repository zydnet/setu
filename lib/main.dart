import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/scan_bloc.dart';
import 'presentation/bloc/ngo_bloc.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error (using mock data): $e');
  }
  runApp(const SnapGiveApp());
}

class SnapGiveApp extends StatelessWidget {
  const SnapGiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ScanBloc()),
        BlocProvider(create: (_) => NgoBloc()..add(LoadNgosEvent())),
      ],
      child: MaterialApp(
        title: 'SnapGive',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}