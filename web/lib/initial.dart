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
                  flex: 2,
                  child: Stack(
                    children: [
                      Image.network(
                        'assets/assets/gif.gif',
                        isAntiAlias: true,
                        color: theme.colorScheme.primary,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      Image.network(
                        'assets/assets/center.gif',
                        isAntiAlias: true,
                      ),
                    ],
                  )),
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 500,
                              height: 100,
                              child: buildButton("Play", routes.game)),
                          SizedBox(
                              width: 300,
                              height: 50,
                              child: buildButton("Create", routes.setup)),
                        ],
                      ),
                    ),
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
