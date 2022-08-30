
import 'package:coupolerseditor/Models/settings.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../Helpers/strings.dart';
import 'location_picker.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key, required this.lang, required this.settings}) : super(key: key);
  final String lang;
  final Settings settings;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {

  String lang = '';
  

  @override
  void initState() {
    lang = widget.lang;
    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslateText('Settings', language: lang),
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
              TranslateText('Server REST URL:',
                  language: widget.settings.language),
              TextFormField(
                initialValue: widget.settings.baseUrl,
                onChanged: (value) => widget.settings.baseUrl = value,
              ),
              const Divider(),
              Column(
                children: [
                  TextButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LocationPicker(startLocation: LatLng(0, 0),))).then((value) {
                    setState(() {
                      widget.settings.baseLocation = value;
                    });
                  }), icon: const Icon(Icons.location_on_outlined), label: TranslateText('Set base location')),
                  widget.settings.baseLocation != null ? Text('[${widget.settings.baseLocation?.latitude}, ${widget.settings.baseLocation?.longitude}]') : Container()
                ],
              ),
              const SizedBox(
                height: 100,
              ),
              TextButton.icon(
                  onPressed: () {
                    widget.settings.saveSettings();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: TranslateText('Save to device',
                      language: widget.settings.language))
            ],
          ),
        ),
      ),
    );
  }
}