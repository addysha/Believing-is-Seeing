import 'package:flutter/material.dart';
import 'main.dart';
import 'routes.dart' as routes;

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  Widget buildButton(String text, String path) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          maxWidth: 120, minWidth: 80, maxHeight: 80, minHeight: 80),
      child: ElevatedButton(
        style: ButtonStyle(
            shape: MaterialStatePropertyAll(BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(20)))),
        child: Text(text),
        onPressed: () {
          navKey.currentState?.pushNamed(path);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size sizeOfScreen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                theme.colorScheme.surface,
                theme.colorScheme.secondary.withOpacity(.2),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
          ),
          Positioned.fill(
            top: sizeOfScreen.height * (3 / 5),
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface),
            ),
          ),
          Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Believing is Seeing",
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
              )),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Expanded(child: buildButton("Create", routes.setup)),
                    const Spacer(),
                    Expanded(child: buildButton("Play", routes.game)),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
