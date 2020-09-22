import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bluu/models/log.dart';
import 'package:bluu/resources/local_db/interface/log_interface.dart';

class HiveMethods implements LogInterface {
  String _hiveBox;

  openDb(String dbName) => _hiveBox = dbName; 

  @override
  init() async {
    final Directory d = await getApplicationDocumentsDirectory();
    Hive.init(d.path);
  }

  @override
  addLogs(Log log) async {
    final Box box = await Hive.openBox(_hiveBox);
    var logMap = log.toMap(log);
    int idOfInput = await box.add(logMap);
    Hive.close();
    return idOfInput;
  }

  @override
  Future<List<Log>> getLogs() async {
    final Box box = await Hive.openBox(_hiveBox);
    List<Log> list = [];

    for (int i = 0; i < box.length; i++) {
      var logMap = box.getAt(i);
      list.add(
        Log.fromMap(
          logMap,
        ),
      );
    }

    return list;
  }

  @override
  deleteLogs(int logId) async {
    final Box box = await Hive.openBox(_hiveBox);
    await box.deleteAt(logId);
  }

  @override
  close() => Hive.close();
}
