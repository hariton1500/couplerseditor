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
  'Create/edit coupler': {
    'en': 'Create/edit coupler',
    'ru': 'Создать/редактировать муфту',
  },
  'Location:': {
    'en': 'Location:',
    'ru': 'Расположение:',
  },
  'Location Picker': {
    'en': 'Location Picker',
    'ru': 'Выбор расположения',
  },
  'Marking:': {'en': 'Marking', 'ru': 'Маркировка:'},
  'Edit / View fiber comments:': {
    'en': 'Edit / View fiber comments:',
    'ru': 'Редактирование/Просмотр:'
  },
  'Edit/View fibers': {
    'en': 'Edit/View fibers',
    'ru': 'Редактирование/Просмотр волокон'
  },
  'List of couplers from billing': {
    'en': 'List of couplers from billing',
    'ru': 'Список муфт из биллинга'
  },
  'List of couplers from device': {
    'en': 'List of couplers from device',
    'ru': 'Список муфт из устройства'
  },
  'List of couplers is Loading or Empty': {
    'en': 'List of couplers is Loading or Empty',
    'ru': 'Список муфт загружается или пуст'
  },
  'Delete coupler': {'en': 'Delete coupler', 'ru': 'Удалить муфту'},
  'Are you sure you want to delete coupler?': {
    'en': 'Are you sure you want to delete coupler?',
    'ru': 'Вы уверены, что хотите удалить муфту?'
  },
  'Load from billing software (json)': {
    'en': 'Load from billing software (json)',
    'ru': 'Загрузить из биллинга (json)'
  },
  'Fibers with comments and spliters:': {
    'en': 'Fibers with comments and spliters:',
    'ru': 'Волокона с комментариями и делителями:'
  },
  'Spliter on': {
    'en': 'Spliter of ',
    'ru': 'Делитель на '
  },
};

class TranslateText extends Text {
  TranslateText(String text, {Key? key, String language = 'en', double size = 10.0})
      : super(
          strings[text]?[language] ?? text,
          key: key,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
          ),
        );
}
