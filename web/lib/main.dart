import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web/game.dart';
import 'package:web/setup.dart';
import 'apikey.dart';
import 'initial.dart';
import 'routes.dart' as routes;
// import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      // MultiProvider(providers: const [], child:
      const MyApp()
      // )
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

late GlobalKey<NavigatorState> navKey;

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState

    navKey = GlobalKey<NavigatorState>();

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seeing is Seeing',
      theme: ThemeData(
          primarySwatch: Colors.deepOrange, brightness: Brightness.dark),
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            return navKey.currentState?.canPop() ?? false == false;
          },
          child: Navigator(
            key: navKey,
            initialRoute: routes.initpage,
            onGenerateRoute: (settings) {
              late Widget returnWidget;

              switch (settings.name) {
                case routes.game:
                  returnWidget = const GamePage();

                  break;
                case routes.setup:
                  returnWidget = const SetupPage();

                  break;
                case routes.changeApiKey:
                  returnWidget = ApiKey();

                  break;
                default:
                  returnWidget = const InitialPage();
              }

              return MaterialPageRoute(
                builder: (context) {
                  return returnWidget;
                },
                settings: settings,
              );
            },
          ),
        );
      },
    );
  }
}
