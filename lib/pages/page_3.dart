import 'package:flutter/material.dart';

class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  int _clicks = 0;

  void _increase() {
    setState(() {
      _clicks = _clicks + 1;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_clicks',
            style: const TextStyle(
              fontSize: 48,
            ),
          ),
          TextButton(
            onPressed: _increase,
            child: const Text("+"),
          )
        ],
      ),
    );
  }
}
