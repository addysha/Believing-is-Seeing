import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'keys.dart';

class ApiKey extends StatelessWidget {
  ApiKey({super.key});

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            Expanded(
              child: TextField(
                controller: controller,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  apiKey = controller.text.trim();
                },
                child: const Text("Update")),
            const Spacer(),
          ],
        ),
        const Spacer(),
      ]),
    );
  }
}
