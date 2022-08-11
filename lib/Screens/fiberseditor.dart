import 'package:flutter/material.dart';

import '../Helpers/spliters.dart';
import '../Helpers/strings.dart';
import '../Models/cableend.dart';

class FibersEditor extends StatefulWidget {
  final String lang;
  final CableEnd cableEnd;

  const FibersEditor({Key? key, required this.lang, required this.cableEnd})
      : super(key: key);

  @override
  State<FibersEditor> createState() => _FibersEditorState();
}

class _FibersEditorState extends State<FibersEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslateText(
          'Fibers Editor',
          language: widget.lang,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Wrap(
              children: [
                TranslateText('Direction: ', language: widget.lang),
                Text(widget.cableEnd.direction),
              ],
            ),
            Column(
              //shrinkWrap: true,
              //physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                  widget.cableEnd.fibersNumber,
                  (index) => Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((index + 1).toString()),
                          ),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: widget.cableEnd.fiberComments[index]),
                              onChanged: (value) {
                                widget.cableEnd.fiberComments[index] = value;
                              },
                            ),
                          ),
                          Checkbox(
                            value: widget.cableEnd.spliters[index] > 0,
                            onChanged: (bool? isSpliter) {
                              print(isSpliter);
                              isSpliter!
                                  ? showDialog<int>(
                                      context: context,
                                      builder: (cntx) {
                                        print(widget.cableEnd.spliters);
                                        print(index);
                                        if (widget.cableEnd.spliters.isEmpty) {
                                          widget.cableEnd.spliters =
                                              List.filled(
                                                  widget.cableEnd.fibersNumber,
                                                  0);
                                        }
                                        return AlertDialog(
                                            actions: [
                                              OutlinedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(
                                                          widget.cableEnd
                                                              .spliters[index]),
                                                  child: const Text('Ok'))
                                            ],
                                            content: Column(
                                              children: List.generate(
                                                  spliterList.length,
                                                  (spliter) => OutlinedButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(spliterList[
                                                                  spliter]),
                                                      child: Text(
                                                          spliterList[spliter]
                                                              .toString()))),
                                            ));
                                      }).then((value) => setState(
                                        () {
                                          widget.cableEnd.spliters[index] =
                                              value!;
                                        },
                                      ))
                                  : setState(() =>
                                      widget.cableEnd.spliters[index] = 0);
                            },
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
