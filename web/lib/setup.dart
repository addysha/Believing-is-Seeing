import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:openai_client/openai_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recase/recase.dart';
import 'classes.dart';
import 'package:image_network/image_network.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'keys.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

Uuid uuid = const Uuid();

class _SetupPageState extends State<SetupPage> {
  bool tempIsPossible = false;

  List<GameItem> tempGames = [];

  Random rng = Random();

  String? previousUrl;

  late OpenAIClient aiClient;

  TextEditingController person1Controller = TextEditingController();
  TextEditingController person2Controller = TextEditingController();
  TextEditingController actionController = TextEditingController();
  TextEditingController additionalPrompt = TextEditingController();

  String? selectedImage;

  bool generateLoading = false;

  //Logic for upload the prompts and images to cloud firestore
  Future<void> uploadButton() async {
    String? errorText;
    TextEditingController nameController = TextEditingController();

    //creating a dialog and waiting for it to complete
    await NDialog(
      title: const Text("Upload"),
      //custom State that is managed internally via the "ss" method (setstate)
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
                  onPressed: () async {
                    //error checking, if theres an error and we need  to rebuild
                    //the widgets, we call the ss method
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

                      //grab instance of database
                      CollectionReference gamesRef =
                          FirebaseFirestore.instance.collection('Games');
                      final docRef = gamesRef.doc();

                      Map<String, dynamic> dataForDoc = {
                        'name': nameController.text.trim(),
                        'docId': docRef.id
                      };

                      //iterate through all the custom games
                      //and add them to the document we're uploading
                      for (var element in tempGames) {
                        dataForDoc[element.id] = {
                          'prompt': element.prompt,
                          'person1': element.person1,
                          'person2': element.person2,
                          'interaction': element.interaction,
                          'isPossible': element.isPossible,
                          'url': element.url,
                          'id': element.id,
                          'urlName': "${element.prompt.snakeCase}-${uuid.v4()}"
                        };
                      }

                      //upload MAP/dict/json to database
                      docRef.set(dataForDoc);

                      setState(() {
                        //rebuilding the entire page after clearing the just uploaded games
                        Navigator.of(context).pop();
                        tempGames.clear();
                      });
                    } catch (e) {
                      //dumb error handling
                      ss(
                        () {
                          errorText = e.toString();
                        },
                      );
                    }
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

  Future<void> generateButton() async {
    //bool check so we cant generate twice in rapid succession
    if (generateLoading) return;
    String badCategories = "";
    selectedImage = null;
    bool moderationThrow = false;

    try {
      if (!isCustomPrompt &&
          (selectedPerson1 == null || selectedPerson2 == null)) {
        const NDialog(
          content: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Please select two people to generate a prompt"),
          ),
        ).show(context);
        return;
      }
      setState(() {
        generateLoading = true;
      });
      Response<Images> response;
      String prompt = "";

      if (isCustomPrompt) {
        prompt =
            "${person1Controller.text} ${actionController.text} ${person2Controller.text} ";
      } else {
        prompt =
            "${selectedPerson1!.name} ${actionController.text} ${selectedPerson2!.name} ";
      }

      prompt += additionalPrompt.text.trim();

      //moderation API check (pointless)
      final moderationResponse = await http.post(
          Uri.parse('https://api.openai.com/v1/moderations'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey"
          },
          body: {"\"input\"": "\"$prompt\""}.toString());

      final decodedJson = jsonDecode(utf8.decode(moderationResponse.bodyBytes));
      final Map decodedMap = Map.from(decodedJson);
      //it will always contain results, unless theres an error
      if (decodedMap.containsKey('results')) {
        final resultsJson = decodedJson['results'];
        final Map resultsMap = Map.from(resultsJson.first);
        final categories = Map.from(resultsMap['categories']);

        bool flagged = resultsMap['flagged'];

        //there are several categories
        //https://platform.openai.com/docs/guides/moderation/quickstart

        //the below code checks if any of them have been flagged individually
        //unsure if its possible that the main flagged bool is false but a sub
        //category is true, but checking anyway

        if (!flagged) {
          for (var element in categories.entries) {
            flagged = flagged || element.value;
          }
        }

        if (flagged) {
          badCategories = "Areas Flagged:\n";
          for (var element
              in categories.entries.where((element) => element.value)) {
            badCategories += element.key.toString().titleCase;
            badCategories += "\n";
          }
          moderationThrow = true;
          throw Exception(
              'Content not allowed by OpenAI moderation standards.');
        }
      }

      //using openai dart api library
      setState(() {
        displayedUrls.clear();
      });
      response = await aiClient.images
          .create(
            size: ImageSize.large,
            n: 4,
            prompt: prompt,
          )
          .go();

      Images data = response.get();
      List<Content> content = data.data;

      displayedUrls.clear();

      //this subfunction was initially downloading the images to the local
      //app instance but because of COORS restrictions, that logic is now removed
      //however it was made so instead of awaiting one download after another
      //all of the futures could be added to a list, and all 4 downloads could be
      //waited for at once
      //
      // await Future.wait(futures);   <----

      Future<void> grabData(String url) async {
        displayedUrls[url] = url;
      }

      List<Future> futures = [];
      for (var element in content) {
        futures.add(grabData(element.url));
      }

      await Future.wait(futures);
      //telling the main widget to rebuild
      setState(() {});
    } catch (e) {
      NDialog(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Error"),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(moderationThrow
                    ? e.toString()
                    : 'Error with OpenAI services, your prompt may be innappropriate.')),
            if (badCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(badCategories),
              ),
          ],
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
    final conf = OpenAIConfiguration(
      apiKey: apiKey,
    );

// Create a new client
    aiClient = OpenAIClient(configuration: conf);
  }

  bool isCustomPrompt = false;

  void saveButtonPress() {
    setState(() {
      if (isCustomPrompt) {
        tempGames.add(GameItem(
            uuid.v4(),
            selectedImage!,
            "${person1Controller.text.trim()} ${actionController.text.trim()} ${person2Controller.text.trim()}",
            person1Controller.text.trim(),
            person2Controller.text.trim(),
            actionController.text.trim(),
            tempIsPossible));
      } else {
        if (selectedPerson1 == null || selectedPerson2 == null) {
          throw Exception('Ensure people are selected');
        }
        tempGames.add(GameItem(
            uuid.v4(),
            selectedImage!,
            "${selectedPerson1!.name.trim()} ${actionController.text.trim()} ${selectedPerson2!.name.trim()}",
            selectedPerson1!.name.trim(),
            selectedPerson2!.name.trim(),
            actionController.text.trim(),
            selectedPerson1!.aliveSameTime(selectedPerson2!)));
      }
    });
  }

  List<PersonItem> people = [];

  void toggleCustomPersonCreation(bool value) {
    setState(() {
      isCustomPrompt = value;
    });
  }

  PersonItem? selectedPerson1;

  int person1SliderBirth = 1500;
  int person1SliderDeath = 2023;
  int person2SliderBirth = 1500;
  int person2SliderDeath = 2023;

  PersonItem? selectedPerson2;

  Widget generatePopupMenuList(bool isPerson1) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey.shade700,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(isPerson1
                          ? (selectedPerson1?.name ?? "Select person 1")
                          : (selectedPerson2?.name ?? "Select person 2")),
                    ),
                    const Icon(Icons.arrow_drop_down_circle_sharp),
                  ],
                ),
                itemBuilder: (context) {
                  int i = 0;
                  List<PopupMenuItem> returnList = [];
                  for (var element in people) {
                    if (isPerson1) {
                      if (element.birthdate.year < person1SliderBirth) continue;
                      if (element.birthdate.year > person1SliderDeath) continue;
                    } else {
                      if (element.birthdate.year < person2SliderBirth) continue;
                      if (element.birthdate.year > person2SliderDeath) continue;
                    }

                    i++;
                    returnList.add(
                      PopupMenuItem(
                          padding: EdgeInsets.zero,
                          onTap: () {
                            setState(() {
                              if (isPerson1) {
                                selectedPerson1 = element;
                              } else {
                                selectedPerson2 = element;
                              }
                            });
                          },
                          child: Container(
                            color: i.isEven ? null : Colors.grey.shade700,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          element.name.titleCase,
                                          style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 20),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            "Birthdate: ${DateFormat('yyyy-MM-dd').format(element.birthdate)}"),
                                      ),
                                      if (element.deathdate != null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              "Deathdate: ${DateFormat('yyyy-MM-dd').format(element.deathdate!)}"),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          element.isDead
                                              ? "Not Alive"
                                              : "Alive",
                                          style: TextStyle(
                                              color: element.isDead
                                                  ? Colors.red
                                                  : Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    );
                  }

                  return returnList;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    List<Widget> displayImages = [];
    for (var i = 0; i < displayedUrls.length; i++) {
      var entry = displayedUrls.entries.elementAt(i);

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

    Widget actionTextBox = Padding(
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
    );

    Widget presetBuilder = FutureBuilder(
      future: FirebaseFirestore.instance.collection('TestCollection').get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          people.clear();
          for (var element in snapshot.data!.docs) {
            final newPerson = PersonItem.fromJson(element.data());
            people.add(newPerson);
          }
          people.sort((a, b) => a.birthdate.compareTo(b.birthdate));
        }

        bool loading = people.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            if (loading)
              const CircularProgressIndicator()
            else ...[
              generatePopupMenuList(true),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text('Birthdate after, year: $person1SliderBirth'),
              ),
              Slider(
                  value: person1SliderBirth.toDouble(),
                  min: 1500,
                  max: 2023,
                  onChanged: (val) => setState(() {
                        if (val > person1SliderDeath) return;
                        person1SliderBirth = val.round();
                      })),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text('Deathdate before, year: $person1SliderDeath'),
              ),
              Slider(
                  value: person1SliderDeath.toDouble(),
                  min: 1500,
                  max: 2023,
                  onChanged: (val) => setState(() {
                        if (person1SliderBirth > val) return;
                        person1SliderDeath = val.round();
                      })),
            ],
            const SizedBox(
              height: 15,
            ),
            actionTextBox,
            const SizedBox(
              height: 15,
            ),
            if (loading)
              const CircularProgressIndicator()
            else ...[
              generatePopupMenuList(false),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text('Birthdate after, year: $person2SliderBirth'),
              ),
              Slider(
                  value: person2SliderBirth.toDouble(),
                  min: 1500,
                  max: 2023,
                  onChanged: (val) => setState(() {
                        if (val > person2SliderDeath) return;
                        person2SliderBirth = val.round();
                      })),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text('Deathdate before, year: $person2SliderDeath'),
              ),
              Slider(
                  value: person2SliderDeath.toDouble(),
                  min: 1500,
                  max: 2023,
                  onChanged: (val) => setState(() {
                        if (person2SliderBirth > val) return;
                        person2SliderDeath = val.round();
                      })),
            ],
            const SizedBox(
              height: 15,
            ),
          ],
        );
      },
    );

    Widget customBuilder = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
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
        const SizedBox(
          height: 15,
        ),
        actionTextBox,
        const SizedBox(
          height: 15,
        ),
        Padding(
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
        const SizedBox(
          height: 15,
        ),
      ],
    );

    Widget savedItems = GridView.builder(
      itemCount: tempGames.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 5, crossAxisSpacing: 5, crossAxisCount: 1),
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
          LayoutBuilder(builder: (context, con) {
            return SizedBox.square(dimension: con.maxHeight, child: images);
          }),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: Column(children: [
                Container(
                  color: theme.colorScheme.primary,
                  child: SwitchListTile(
                      title: const Text("Custom Prompt?"),
                      value: isCustomPrompt,
                      onChanged: toggleCustomPersonCreation),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCustomPrompt)
                              customBuilder
                            else
                              presetBuilder,
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: additionalPrompt,
                                onSubmitted: (value) {
                                  generateButton();
                                },
                                decoration: const InputDecoration(
                                  label: Text("Additional Prompt"),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
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
                            const SizedBox(
                              height: 15,
                            ),
                          ]),
                    ),
                  ),
                ),
                if (isCustomPrompt)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Not Possible?"),
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
                              const Text("Possible?"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else if (selectedPerson1 != null && selectedPerson2 != null)
                  Text(
                    "Could happen? ${selectedPerson1!.aliveSameTime(selectedPerson2!) ? "Yes" : "No"}",
                    style: TextStyle(
                        color: selectedPerson1!.aliveSameTime(selectedPerson2!)
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold),
                  )
                else
                  const Text("Select two people"),
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
              ]),
            ),
          ),
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
          ),
        ],
      ),
    );
  }
}
