import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:ndialog/ndialog.dart';

import 'classes.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

enum GameState { picking, playing, postgameResults }

class _GamePageState extends State<GamePage> {
  bool panelOpen = true;
  double panelWidth = 300;
  double buttonWidth = 30;

  Game? selectedGame;

  List<Game> loadedGames = [];

  Map<GameItem, bool?> guesses = {};

  void selectGame(Game newGame) {
    if (selectedGame == newGame) return;

    setState(() {
      panelOpen = false;
      gameState = GameState.playing;
      selectedGame = newGame;
    });

    guesses.clear();

    guesses = newGame.gameItems.fold<Map<GameItem, bool?>>({},
        (previousValue, element) {
      previousValue[element] = null;
      return previousValue;
    });
  }

  GameState gameState = GameState.picking;

  Random rng = Random();

  Widget buildPickerWidget(GameItem game, ThemeData theme) {
    Future<void> setChoice(bool value) async {
      setState(() {
        guesses[game] = value;
      });

      if (getRemainingGames.isEmpty && selectedGame != null) {
        TextEditingController nameController = TextEditingController();

        Future<void> uploadResults() async {
          Navigator.pop(context);

          final instance = FirebaseFirestore.instance;
          instance.collection('Games').doc(selectedGame!.docId).update({
            "results": {
              if (selectedGame!.results != null) ...selectedGame!.results!,
              nameController.text.trim(): getCorrectGuesses,
            }
          });
        }

        await NDialog(
          title: const Text("Save your score"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration:
                      const InputDecoration(hintText: "Input your name"),
                  controller: nameController,
                  onEditingComplete: () {
                    uploadResults();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    ElevatedButton(
                        onPressed: uploadResults,
                        child: const Text("Upload Results")),
                  ],
                ),
              )
            ],
          ),
        ).show(
          context,
          transitionType: DialogTransitionType.Bubble,
          dismissable: false,
        );
      }
    }

    return IgnorePointer(
      ignoring: panelOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setChoice(true);
              },
              child: Center(
                child: Text(
                  "Possible?",
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  child: ImageNetwork(
                      key: Key(game.url.toString()),
                      image: game.url,
                      height: 1000,
                      width: 1000,
                      duration: 1500,
                      curve: Curves.easeIn,
                      fullScreen: true,
                      fitAndroidIos: BoxFit.cover,
                      fitWeb: BoxFitWeb.cover,
                      onLoading: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      onError: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      onTap: null),
                ),
              )),
          Expanded(
            child: InkWell(
              onTap: () {
                setChoice(false);
              },
              child: Center(
                  child: Text(
                "Not Possible?",
                style: theme.textTheme.titleLarge,
              )),
            ),
          ),
        ],
      ),
    );
  }

  int get getCorrectGuesses => guesses.entries
      .where((element) => element.value == element.key.isPossible)
      .length;

  bool didAGoodJob() {
    int length = guesses.length;

    return (getCorrectGuesses / length) > .5;
  }

  Widget buildResultScreen(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        didAGoodJob()
                            ? "Good work!"
                            : "Better luck next time...",
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: guesses.length,
                        itemBuilder: (context, index) {
                          MapEntry<GameItem, bool?> result =
                              guesses.entries.elementAt(index);

                          return Container(
                            color: (result.value == result.key.isPossible
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(.2),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IgnorePointer(
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 100,
                                    height: 200,
                                    child: ImageNetwork(
                                        key: Key(result.key.url.toString()),
                                        image: result.key.url,
                                        height: 200,
                                        width: 200,
                                        duration: 1500,
                                        curve: Curves.easeIn,
                                        onPointer: true,
                                        fullScreen: true,
                                        fitAndroidIos: BoxFit.cover,
                                        fitWeb: BoxFitWeb.fill,
                                        onLoading:
                                            const CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
                                        onError: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                        onTap: null),
                                  ),
                                  title: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(result.key.prompt,
                                            style: theme.textTheme.titleLarge),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Your answer: ",
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                (result.value!
                                                    ? "Possible"
                                                    : "Not Possible"),
                                                style: theme
                                                    .textTheme.titleMedium),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Correct Answer: ",
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              (result.key.isPossible
                                                  ? "Possible"
                                                  : "Not Possible"),
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Previous Scores",
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: selectedGame!.results == null
                          ? const SizedBox()
                          : ListView.builder(
                              itemCount: selectedGame!.results!.length,
                              itemBuilder: (context, index) {
                                MapEntry<String, dynamic> result = selectedGame!
                                    .results!.entries
                                    .elementAt(index);

                                return Container(
                                  color: theme.cardColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IgnorePointer(
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                result.key,
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("Score: "),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                (result.value).toString(),
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  GameItem? currentGameItem;
  Map<GameItem, bool?> get getRemainingGames =>
      Map<GameItem, bool?>.fromEntries(
          guesses.entries.where((element) => element.value == null));

  Widget buildScreenWidget(ThemeData theme) {
    if (gameState.index == 0 || selectedGame == null) {
      return const Center(child: Text("Choose a game!"));
    }
    if (guesses.containsValue(null)) {
      currentGameItem = getRemainingGames.entries.first.key;

      return buildPickerWidget(currentGameItem!, theme);
    } else {
      currentGameItem = null;
      return buildResultScreen(theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          // elevation: 0,
          // backgroundColor: Colors.transparent,

          title: Row(
            children: [
              const Spacer(
                flex: 2,
              ),
              if (selectedGame != null)
                Expanded(
                  child: ListTile(
                    title: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Show prompt"),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.lightbulb),
                          )
                        ]),
                    onTap: () {
                      NDialog(
                        content: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(currentGameItem!.prompt),
                        ),
                      ).show(context);
                    },
                  ),
                )
              else
                const Text("Play game!"),
              const Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
        body: Stack(children: [
          Positioned.fill(child: buildScreenWidget(theme)),
          AnimatedPositioned(
            width: panelWidth,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            right: panelOpen ? 0 : -(panelWidth - buttonWidth),
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: panelWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: buttonWidth,
                    height: buttonWidth * 2,
                    color: theme.colorScheme.primaryContainer,
                    child: InkWell(
                      onTap: () => setState(() {
                        panelOpen = !panelOpen;
                      }),
                      child: Icon(
                          panelOpen ? Icons.arrow_right : Icons.arrow_left),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.primary,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Community Games",
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: theme.colorScheme.surface,
                              child: StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Games')
                                      .where('parsed', isEqualTo: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return ListView();
                                    QuerySnapshot<Map<String, dynamic>> data =
                                        snapshot.data!;
                                    return ListView.builder(
                                      itemCount: data.size,
                                      itemBuilder: (context, index) {
                                        var docData = data.docs[index].data();
                                        final game = Game.fromJson(docData);
                                        if (loadedGames.indexWhere((element) =>
                                                element.docId == game.docId) ==
                                            -1) {
                                          loadedGames.add(game);
                                        }
                                        final firstGameItem =
                                            game.gameItems.first;

                                        return IgnorePointer(
                                          ignoring: game == selectedGame,
                                          child: Ink(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectGame(game);
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: IgnorePointer(
                                                  child: ListTile(
                                                    leading: SizedBox.square(
                                                      dimension: 80,
                                                      child: ImageNetwork(
                                                          key: Key(firstGameItem
                                                              .url
                                                              .toString()),
                                                          image:
                                                              firstGameItem.url,
                                                          height: 80,
                                                          width: 80,
                                                          duration: 1500,
                                                          curve: Curves.easeIn,
                                                          onPointer: true,
                                                          fullScreen: false,
                                                          fitAndroidIos:
                                                              BoxFit.cover,
                                                          fitWeb:
                                                              BoxFitWeb.cover,
                                                          onLoading:
                                                              const CircularProgressIndicator(
                                                            color: Colors.blue,
                                                          ),
                                                          onError: const Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                          ),
                                                          onTap: null),
                                                    ),
                                                    title: Text(
                                                      game.name,
                                                      style: theme.textTheme
                                                          .titleMedium,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
