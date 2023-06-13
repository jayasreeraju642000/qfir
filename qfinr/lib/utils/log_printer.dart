import 'package:logger/logger.dart';

Logger getLogger(String className) {
  return Logger(
    printer: SimpleLogPrinter(className),
    output: null,
  );
}

class SimpleLogPrinter extends LogPrinter {
  final String className;
  SimpleLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];
    try {
      print(color('$emoji $className - ${event.message}'));
    } catch (e) {
      print('Null passed to logger: ' + e.toString());
    }
    // return [event.message];
    return [];
  }
}
