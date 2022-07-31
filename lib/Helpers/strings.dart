import 'package:flutter/material.dart';

Map<String, Map<String, String>> strings = {
  'Adding of cable': {
    'en': 'Adding of cable',
    'ru': 'Добавление кабеля',
  },
  'Direction:': {
    'en': 'Direction:',
    'ru': 'Направление:',
  },
  'Number of Fibers:': {
    'en': 'Number of Fibers:',
    'ru': 'Количество волокон:',
  },
  'Length of Cable:': {
    'en': 'Length of Cable:',
    'ru': 'Длина кабеля:',
  },
  'Add cable': {
    'en': 'Add cable',
    'ru': 'Добавить кабель',
  },
  'Add connection': {
    'en': 'Add connection',
    'ru': 'Добавить соединение',
  },
  'Change side': {
    'en': 'Change side',
    'ru': 'Изменить сторону',
  },
  'Change direction': {
    'en': 'Change direction',
    'ru': 'Изменить направление',
  },
  'Change number of fibers': {
    'en': 'Change number of fibers',
    'ru': 'Изменить количество волокон',
  },
  'Delete cable': {
    'en': 'Delete cable',
    'ru': 'Удалить кабель',
  },
  'Add connections': {
    'en': 'Add connections',
    'ru': 'Добавить соединения',
  },
  'Delete connection': {
    'en': 'Delete connection',
    'ru': 'Удалить соединение',
  },
  'Delete all connections': {
    'en': 'Delete all connections',
    'ru': 'Удалить все соединения',
  },
  'Coupler name:': {
    'en': 'Coupler name:',
    'ru': 'Название муфты:',
  },
  'Export': {
    'en': 'Export',
    'ru': 'Экспорт',
  },
  'Import': {
    'en': 'Import',
    'ru': 'Импорт',
  },
  'Back': {
    'en': 'Back',
    'ru': 'Назад',
  },
  'Save': {
    'en': 'Save',
    'ru': 'Сохранить',
  },
  'Cancel': {
    'en': 'Cancel',
    'ru': 'Отмена',
  },
  'Delete': {
    'en': 'Delete',
    'ru': 'Удалить',
  },
  'Delete all': {
    'en': 'Delete all',
    'ru': 'Удалить все',
  },
  'Create': {
    'en': 'Create',
    'ru': 'Создать',
  },
  'Settings': {
    'en': 'Settings',
    'ru': 'Настройки',
  },
  'Name editing': {
    'en': 'Name editing',
    'ru': 'Редактирование названия',
  },
  'Adding of cable:': {
    'en': 'Adding of cable',
    'ru': 'Добавление кабеля',
  },
  'From:': {
    'en': 'From:',
    'ru': 'От:',
  },
  'To:': {
    'en': 'To:',
    'ru': 'До:',
  },
  'Language:': {
    'en': 'Language:',
    'ru': 'Язык:',
  },
  'Load list of couplers URL:': {
    'en': 'Load list of couplers URL:',
    'ru': 'URL для загрузки списка муфт:',
  },
  'Hide': {
    'en': 'Hide',
    'ru': 'Скрыть',
  },
  'Save to device': {
    'en': 'Save to device',
    'ru': 'Сохранить на устройство',
  },
  'Load from device': {
    'en': 'Load from device',
    'ru': 'Загрузить с устройства',
  },
  'Load from URL': {
    'en': 'Load from URL',
    'ru': 'Загрузить по URL',
  },
  'Create new coupler': {
    'en': 'Create new coupler',
    'ru': 'Создать новую муфту',
  },
  'Location:': {
    'en': 'Location:',
    'ru': 'Расположение:',
  },
  'Location Picker': {
    'en': 'Location Picker',
    'ru': 'Выбор расположения',
  },
};

class TranslateText extends Text {
  TranslateText(String text, {Key? key, String language = 'en'})
      : super(
          strings[text]?[language] ?? text,
          key: key,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
}
