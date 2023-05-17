import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        // backgroundColor: Colors.transparent,
        title: const Text("Play game!"),
      ),
      body: Row(
        children: [
          const Spacer(
            flex: 3,
          ),
          Expanded(
            child: Container(
              color: Colors.black.withOpacity(.05),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Games')
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return ListView();
                    QuerySnapshot<Map<String, dynamic>> data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        var docData = data.docs[index].data();
                        var firstGameData = docData.entries.firstWhere(
                          (element) => element.key != "name",
                        );

                        return ListTile(
                          leading: SizedBox.square(
                            dimension: 80,
                            child: ImageNetwork(
                                key: Key(firstGameData.value['url'].toString()),
                                image: firstGameData.value['url'],
                                height: 80,
                                width: 80,
                                duration: 1500,
                                curve: Curves.easeIn,
                                onPointer: true,
                                fullScreen: false,
                                fitAndroidIos: BoxFit.cover,
                                fitWeb: BoxFitWeb.cover,
                                onLoading: const CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                                onError: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                                onTap: null),
                          ),
                          title: Text(docData['name']),
                        );
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
