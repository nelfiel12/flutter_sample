import 'dart:developer' as dev;

void debug(String value) {
  DateTime time = DateTime.now();

  String log = '[BOGO] '
      '${time.year.toString()}'
      '${time.month.toString().padLeft(2, '0')}'
      '${time.day.toString().padLeft(2, '0')}'
      '_'
      '${time.hour.toString().padLeft(2, '0')}'
      ':'
      '${time.minute.toString().padLeft(2, '0')}'
      ':'
      '${time.second.toString().padLeft(2, '0')}'
      '.'
      '${time.microsecond.toString().padLeft(3, '0')} : $value';

  dev.log(log, name: 'debug');
}

void error(String value) {
  DateTime time = DateTime.now();

  String log = '[BOGO] '
      '${time.year.toString()}'
      '${time.month.toString().padLeft(2, '0')}'
      '${time.day.toString().padLeft(2, '0')}'
      '_'
      '${time.hour.toString().padLeft(2, '0')}'
      ':'
      '${time.minute.toString().padLeft(2, '0')}'
      ':'
      '${time.second.toString().padLeft(2, '0')}'
      '.'
      '${time.microsecond.toString().padLeft(3, '0')} : $value';

  dev.log(log, name: 'error');
}