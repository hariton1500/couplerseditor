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
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              (index + 1).toString(),
              style: TextStyle(
                color:
                    (index == 7 || index == 19) ? Colors.white : Colors.black,
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
  },
  {
    'name': 'L2 Commutator 48',
    'value': {'ports': 48},
  },
];
