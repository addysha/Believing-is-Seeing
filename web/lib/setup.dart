import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:openai_client/openai_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'classes.dart';
import 'package:image_network/image_network.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  bool tempIsPossible = false;

  List<GameItem> tempGames = [];

  Random rng = Random();

  String? previousUrl;
  late OpenAIClient aiClient;
  TextEditingController person1Controller = TextEditingController();
  TextEditingController person2Controller = TextEditingController();
  TextEditingController actionController = TextEditingController();

  String? selectedImage;

  bool generateLoading = false;

  Future<void> uploadButton() async {
    String? errorText;
    TextEditingController nameController = TextEditingController();
    await NDialog(
      title: const Text("Upload"),
      content: StatefulBuilder(builder: (context, ss) {
        ThemeData theme = Theme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  errorText: errorText,
                  hintText: "\n",
                  label: Text(
                    "Game Name",
                    style: TextStyle(
                        color:
                            errorText != null ? theme.colorScheme.error : null),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                  onPressed: () {
                    try {
                      ss(
                        () {
                          errorText = null;
                        },
                      );
                      if (tempGames.length < 3) {
                        ss(
                          () {
                            errorText =
                                "A minimum of 3 questions are required per game.";
                          },
                        );
                        return;
                      }
                      CollectionReference gamesRef =
                          FirebaseFirestore.instance.collection('Games');
                      Reference imageRef =
                          FirebaseStorage.instance.ref('GameImages');

                      Map<String, dynamic> dataForDoc = {
                        'name': nameController.text.trim()
                      };

                      for (var element in tempGames) {
                        dataForDoc[element.id] = {
                          'prompt': element.prompt,
                          'isPossible': element.isPossible,
                          'url': element.url
                        };
                      }
                      gamesRef.add(dataForDoc);

                      setState(() {
                        Navigator.of(context).pop();
                        tempGames.clear();
                      });
                    } finally {}
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Upload"),
                  )),
            )
          ],
        );
      }),
    ).show(context);
  }

  Map<String, dynamic> displayedUrls = {};

  // Future<Uint8List?> loadImage(String imageUrl) async {
  //   final Uri uri = Uri.parse(imageUrl);
  //   final HttpClient httpClient = HttpClient();
  //   Uint8List? imageBytes;

  //   try {
  //     final HttpClientRequest request = await httpClient.getUrl(uri);
  //     final HttpClientResponse response = await request.close();
  //     if (response.statusCode == HttpStatus.ok) {
  //       final List<Uint8List> chunks = [];
  //       await for (final Uint8List chunk in response
  //           .transform(const AccumulatorTransformer<Uint8List>(chunks))) {
  //         chunks.add(chunk);
  //       }
  //       imageBytes =
  //           Uint8List.fromList(chunks.expand((chunk) => chunk).toList());
  //     } else {
  //       throw Exception('Failed to load image');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   } finally {
  //     httpClient.close();
  //   }
  //   return imageBytes;
  //   // Do something with the imageBytes
  // }

  // Future<Uint8List> fetchImageData(String url) async {
  //   final urlParsed = Uri.encodeFull(url);

  //   final response = await http.get(Uri.parse(urlParsed));
  //   NetworkImage(url, scale: 1, headers: {}).load(url, (buffer, {allowUpscaling, cacheHeight, cacheWidth}) => null);
  //   if (response.statusCode == 200) {
  //     final bodyBytes = response.bodyBytes;
  //     final uint8List = Uint8List.fromList(bodyBytes);
  //     return uint8List;
  //   } else {
  //     throw Exception('Failed to fetch image');
  //   }
  // }

  Future<void> generateButton() async {
    if (generateLoading) return;
    try {
      setState(() {
        generateLoading = true;
      });
      Response<Images> response;

      // if (selectedImage != null) {
      //   response = await aiClient.images
      //       .edit(
      //         image: selectedImage!,
      // responseFormat: ResponseFormat.b64Json,
      //         n: 4,
      //         prompt:
      //             "${person1Controller.text} ${actionController.text} ${person2Controller.text}",
      //       )
      //       .go();
      // } else {
      response = await aiClient.images
          .create(
            size: ImageSize.medium,
            n: 1,
            prompt:
                "${person1Controller.text} ${actionController.text} ${person2Controller.text}",
          )
          .go();
      // // }

      Images data = response.get();
      List<Content> content = data.data;

      displayedUrls.clear();
      Future<void> grabData(String url) async {
        displayedUrls[url] = url;
      }

      List<Future> futures = [];
      for (var element in content) {
        futures.add(grabData(element.url));
      }
      await Future.wait(futures);
      setState(() {});
    } catch (e) {
      NDialog(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Error"),
        ),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(e.toString()),
        ),
      ).show(context);
    } finally {
      setState(() {
        generateLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Create the configuration
    const conf = OpenAIConfiguration(
      apiKey: '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',
    );

// Create a new client
    aiClient = OpenAIClient(configuration: conf);
  }

  void saveButtonPress() {
    setState(() {
      tempGames.add(GameItem(
          rng.nextDouble().toString(),
          selectedImage!,
          "${person1Controller.text} ${actionController.text} ${person2Controller.text}",
          tempIsPossible));
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    List<Widget> displayImages = [];
    for (var i = 0; i < displayedUrls.length; i++) {
      var entry = displayedUrls.entries.elementAt(i);
      print(entry.value);

      displayImages.add(Stack(
        alignment: Alignment.center,
        children: [
          ImageNetwork(
            key: Key(entry.key.toString()),
            image: entry.key,
            height: 500,
            width: 500,
            duration: 1500,
            curve: Curves.easeIn,
            onPointer: true,
            fullScreen: true,
            fitAndroidIos: BoxFit.cover,
            fitWeb: BoxFitWeb.cover,
            onLoading: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
            onError: const Icon(
              Icons.error,
              color: Colors.red,
            ),
            onTap: () => setState(() {
              if (selectedImage == entry.key) {
                selectedImage = null;
              } else {
                selectedImage = entry.key;
              }
            }),
          ),
          if (selectedImage == entry.key)
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              height: 40,
              width: 40,
              child: const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.red,
                ),
              ),
            )
        ],
      ));
    }

    if (displayImages.isEmpty) {
      for (var i = 0; i < 4; i++) {
        if (generateLoading) {
          displayImages.add(SizedBox.square(
            dimension: 24,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ));
        } else {
          displayImages.add(const Icon(Icons.question_mark));
        }
      }
    }

    Widget images = GridView(
      shrinkWrap: true,
      primary: false,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      children: displayImages,
    );

    Widget savedItems = GridView.builder(
      itemCount: tempGames.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 5, crossAxisSpacing: 5, crossAxisCount: 2),
      itemBuilder: (context, index) {
        GameItem currentItem = tempGames[index];

        String element = currentItem.url;

        return Column(
          children: [
            Expanded(
              child: ImageNetwork(
                key: Key(element.toString()),
                image: element,
                height: 500,
                width: 500,
                duration: 1500,
                curve: Curves.easeIn,
                onPointer: true,
                fullScreen: true,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.cover,
                onLoading: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
                onError: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                onTap: null,
              ),
            ),
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
                    tempGames
                        .removeWhere((element) => element.id == currentItem.id);
                  });
                },
                child: const Icon(Icons.delete)),
          ],
        );
      },
    );

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
                    padding: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(builder: (context, con) {
                      return SizedBox.square(
                          dimension: con.maxHeight, child: images);
                    }),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onSubmitted: (value) {
                                generateButton();
                              },
                              controller: person1Controller,
                              decoration: const InputDecoration(
                                label: Text("Person"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onSubmitted: (value) {
                                generateButton();
                              },
                              controller: actionController,
                              decoration: const InputDecoration(
                                label: Text("Action"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onSubmitted: (value) {
                                generateButton();
                              },
                              controller: person2Controller,
                              decoration: const InputDecoration(
                                label: Text("Another Person"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onSubmitted: (value) {
                                generateButton();
                              },
                              decoration: const InputDecoration(
                                label: Text("Additional Prompt"),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 100,
                            child: ElevatedButton(
                                onPressed: () async {
                                  await generateButton();
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
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedImage == null) return;
                                    saveButtonPress();
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
              Expanded(child: savedItems),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                    onPressed: () async {
                      await uploadButton();
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
