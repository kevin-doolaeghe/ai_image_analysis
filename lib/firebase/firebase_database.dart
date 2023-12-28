import 'package:firebase_database/firebase_database.dart';

class Database {
  Future<void> create(String key, Object? value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(key);
    await ref.set(value);
  }

  Future<Object?> read(String key) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child(key).get();
    if (!snapshot.exists) return null;
    return snapshot.value;
  }

  Future<void> update(String key, Map<String, Object> value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(key);
    await ref.update(value);
  }

  Future<void> delete(String key) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.child(key).remove();
  }
}
