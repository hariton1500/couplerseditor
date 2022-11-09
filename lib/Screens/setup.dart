import 'dart:async';

import 'package:coupolerseditor/Services/server.dart';
import 'package:coupolerseditor/services/location.dart';
import 'package:coupolerseditor/Models/settings.dart';
import 'package:flutter/material.dart';
//import 'package:latlong2/latlong.dart';

import '../Helpers/strings.dart';
import 'location_picker.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key, required this.settings}) : super(key: key);
  final Settings settings;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String lang = '';
  bool isAllAuthFieldsPresent = false;
  DateTime blockTime = DateTime.now();
  bool isShowPassword = false;

  @override
  void initState() {
    //lang = widget.lang;
    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslateText(
          'Settings',
          language: widget.settings.language,
          size: 16,
        ),
        actions: [
          if (isAllAuthFieldsPresent && DateTime.now().isAfter(blockTime)) ...[
            TextButton.icon(
                onPressed: () {
                  Timer(const Duration(seconds: 4), () => setState(() {}));
                  Server server = Server(settings: widget.settings);
                  server.list(type: 'node').then((value) {
                    setState(() {
                      blockTime =
                          DateTime.now().add(const Duration(seconds: 3));
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: TranslateText(value == '' ? 'Error' : 'Ok',
                            language: widget.settings.language,
                            color: value == '' ? Colors.red : Colors.green)));
                  });
                },
                icon: const Icon(Icons.network_check_outlined),
                label: TranslateText('Check Server'))
          ],
          TextButton.icon(
              onPressed: () {
                if (!widget.settings.altServer.endsWith('/')) {
                  widget.settings.altServer += '/';
                }
                widget.settings.saveSettings();
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.save_outlined,
                //color: Colors.black,
              ),
              label: TranslateText('Save', language: widget.settings.language))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              //Settings
              const Divider(),
              TranslateText('Language:', language: widget.settings.language),
              Row(
                children: [
                  Radio<String>(
                      value: 'en',
                      groupValue: widget.settings.language,
                      onChanged: (newLang) =>
                          setState(() => widget.settings.language = newLang!)),
                  const Text('English'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                      value: 'ru',
                      groupValue: widget.settings.language,
                      onChanged: (newLang) =>
                          setState(() => widget.settings.language = newLang!)),
                  const Text('Русский'),
                ],
              ),
              const Divider(),
              TranslateText('Main server URL:',
                  language: widget.settings.language),
              TextFormField(
                initialValue: widget.settings.altServer,
                onChanged: (value) {
                  widget.settings.altServer = value;
                  checkAllAuthFieldsPresent();
                },
              ),
              TranslateText('Login:', language: widget.settings.language),
              TextFormField(
                initialValue: widget.settings.login,
                onChanged: (value) {
                  widget.settings.login = value;
                  checkAllAuthFieldsPresent();
                },
              ),
              TranslateText('Password:', language: widget.settings.language),
              Wrap(
                children: [
                  TextField(
                    //initialValue: widget.settings.password,
                    controller:
                        TextEditingController(text: widget.settings.password),
                    obscureText: !isShowPassword,
                    onChanged: (value) {
                      widget.settings.password = value;
                      checkAllAuthFieldsPresent();
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isShowPassword = !isShowPassword;
                        });
                      },
                      icon: Icon(!isShowPassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded))
                ],
              ),
              const Divider(),
              Column(
                children: [
                  TextButton.icon(
                      onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => LocationPicker(
                                        startLocation: zeroLocation,
                                      )))
                              .then((value) {
                            setState(() {
                              widget.settings.baseLocation = value;
                            });
                          }),
                      icon: const Icon(Icons.location_on_outlined),
                      label: TranslateText('Set base location',
                          language: widget.settings.language)),
                  widget.settings.baseLocation != null
                      ? Text(
                          '[${widget.settings.baseLocation?.latitude}, ${widget.settings.baseLocation?.longitude}]')
                      : Container()
                ],
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkAllAuthFieldsPresent() {
    if (widget.settings.altServer != '' &&
        widget.settings.login != '' &&
        widget.settings.password != '') {
      setState(() {
        isAllAuthFieldsPresent = true;
      });
    } else {
      setState(() {
        isAllAuthFieldsPresent = false;
      });
    }
  }
}
