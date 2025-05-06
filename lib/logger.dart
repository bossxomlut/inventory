import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(),
);

final Logger loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

final Logger routeLogger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

final Logger blocLogger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);
