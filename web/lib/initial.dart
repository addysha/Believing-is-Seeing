import 'package:flutter/material.dart';
import 'main.dart';
import 'routes.dart' as routes;

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size sizeOfScreen = MediaQuery.of(context).size;
    Widget buildButton(String text, String path) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
            maxWidth: 120, minWidth: 80, maxHeight: 80, minHeight: 80),
        child: InkWell(
          borderRadius: BorderRadius.circular(500),
          onTap: () {
            navKey.currentState?.pushNamed(path);
          },
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500),
                gradient: LinearGradient(colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer.withOpacity(.5)
                ])),
            child: Center(
                child: Text(
              text,
              style: theme.textTheme.titleLarge,
            )),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Positioned.fill(
          //   top: sizeOfScreen.height * (3 / 5),
          //   child: Container(
          //     decoration: BoxDecoration(color: theme.colorScheme.surface),
          //   ),
          // ),
          Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Believing is Seeing",
                  style: theme.textTheme.titleLarge
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 500,
                    child: buildButton("Change API Key", routes.changeApiKey)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
