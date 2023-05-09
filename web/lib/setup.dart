import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

import 'classes.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  Image? displayImage;
  bool tempIsPossible = false;

  List<GameItem> tempGames = [];

  Random rng = Random();

  String? previousUrl;

  TextEditingController person1Controller = TextEditingController();
  TextEditingController person2Controller = TextEditingController();
  TextEditingController actionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        // backgroundColor: Colors.transparent,
        title: const Text("Create game"),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Container(
                        color: Colors.black.withOpacity(.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (displayImage != null)
                              Container(child: displayImage)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: person1Controller,
                              decoration: const InputDecoration(
                                label: Text("Insert the name of a person"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: actionController,
                              decoration: const InputDecoration(
                                label: Text("Insert an action"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: person2Controller,
                              decoration: const InputDecoration(
                                label:
                                    Text("Insert the name of another person"),
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                label: Text("Add additional prompt text"),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 100,
                            child: ElevatedButton(
                                onPressed: () {
                                  previousUrl =
                                      "https://picsum.photos/seed/${rng.nextDouble()}}/500";
                                  setState(() {
                                    displayImage = Image.network(previousUrl!);
                                  });
                                },
                                child: const Text("Generate")),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Could not happen?"),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Switch(
                                  value: tempIsPossible,
                                  onChanged: (value) {
                                    setState(() {
                                      tempIsPossible = value;
                                    });
                                  },
                                ),
                              ),
                              const Text("Could Happen?"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: 100,
                              child: OutlinedButton(
                                  onPressed: () {
                                    previousUrl =
                                        "https://picsum.photos/seed/${rng.nextDouble()}}/500";
                                    setState(() {
                                      tempGames.add(GameItem(
                                          rng.nextDouble().toString(),
                                          previousUrl!,
                                          "${rng.nextDouble()} YAYA ${rng.nextDouble()} YAYA ${rng.nextDouble()} YAYA ",
                                          rng.nextBool()));
                                    });
                                  },
                                  child:
                                      const Text("Generate Random (debug)"))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (previousUrl == null) return;
                                    setState(() {
                                      tempGames.add(GameItem(
                                          rng.nextDouble().toString(),
                                          previousUrl!,
                                          person1Controller.text +
                                              actionController.text +
                                              person2Controller.text,
                                          tempIsPossible));
                                    });
                                  },
                                  child: const Text("Save"))),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
          const VerticalDivider(),
          Expanded(
            child: Column(children: [
              Expanded(
                child: GridView.builder(
                  itemCount: tempGames.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    GameItem currentItem = tempGames[index];
                    return Column(
                      children: [
                        Expanded(child: Image.network(currentItem.url)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            currentItem.prompt,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Is It Possible: ${currentItem.isPossible ? "Yes" : "No"}"),
                        ),
                        OutlinedButton(
                            onPressed: () {
                              setState(() {
                                tempGames.removeWhere(
                                    (element) => element.id == currentItem.id);
                              });
                            },
                            child: const Icon(Icons.delete)),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                    onPressed: () {
                      NDialog(
                        title: const Text("Upload"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  label: Text("Game Name"),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Upload"),
                                  )),
                            )
                          ],
                        ),
                      ).show(context);
                    },
                    child: const Text("Create Group")),
              )
            ]),
          )
        ],
      ),
    );
  }
}
