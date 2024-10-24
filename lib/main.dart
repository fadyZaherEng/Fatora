import 'package:fatora/generated/l10n.dart';
import 'package:fatora/src/config/routes/routes_manager.dart';
import 'package:fatora/src/di/injector.dart';
import 'package:fatora/src/presentation/blocs/fatora/fatora_bloc.dart';
import 'package:fatora/src/presentation/screens/main/screen/main_screen.dart';
import 'package:fatora/src/presentation/widgets/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  runApp(
    const RestartWidget(MyApp()),
  );
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FatoraBloc>(
      create: (context) =>FatoraBloc()..add(GetFatoraEvent()),
      child: BlocConsumer<FatoraBloc, FatoraState>(
        listener: (context, state) {

        },
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            navigatorObservers: [
              routeObserver,
            ],
            themeMode: ThemeMode.light,
            supportedLocales: S.delegate.supportedLocales,
            onGenerateRoute: RoutesManager.getRoute,
            home: const MainScreen(),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: 'Fatora',
            locale: const Locale('ar'),
          );
        }
      )
    );
  }
}

