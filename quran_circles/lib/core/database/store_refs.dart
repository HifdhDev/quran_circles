import 'package:sembast/sembast.dart';

class StoreRefs {
  static final students = intMapStoreFactory.store('students');
  static final circles = intMapStoreFactory.store('circles');
  static final attendance = intMapStoreFactory.store('attendance');
  static final memorization = intMapStoreFactory.store('memorization');
  static final messages = intMapStoreFactory.store('messages');
  static final syncRecords = intMapStoreFactory.store('sync_records');
  static final users = intMapStoreFactory.store('users');
  static final settings = StoreRef<String, dynamic>.main();
}
