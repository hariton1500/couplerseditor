
import 'package:coupolerseditor/Models/coupler.dart';
import 'package:flutter/material.dart';

import '../Helpers/strings.dart';

class NodesScreen extends StatefulWidget {
  final String lang;
  final Mufta mufta;

  const NodesScreen({Key? key, required void Function() callback, required this.lang, required this.mufta}) : super(key: key);

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslateText('Nodes:', language: widget.lang,),
      ),
      body: Center(
        child: Text('Nodes'),
      ),
    );
  }
}