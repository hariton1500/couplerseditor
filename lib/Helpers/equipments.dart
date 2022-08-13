import 'package:flutter/material.dart';

List<Map<String, dynamic>> equipmentsList = [
  {
    'name': 'L2 Commutator 10',
    'value': {'ports': 10},
    'widget': Wrap(
      children: List.generate(
        10,
        (index) => Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  },
  {
    'name': 'L2 Commutator 24',
    'value': {'ports': 24},
    'widget': Wrap(
      children: List.generate(
        24,
        (index) => Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  },
  {
    'name': 'L2 Commutator 48',
    'value': {'ports': 48},
    'widget': Wrap(
      children: List.generate(
        48,
        (index) => Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  },
];
