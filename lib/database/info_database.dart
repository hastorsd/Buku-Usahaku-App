import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/model/info.dart';

class InfoDatabase {
  final database = Supabase.instance.client;

  // Create info
  Future<void> createInfo(Info info) async {
    final userId = database.auth.currentUser!.id;
    final data = info.toMap()
      ..remove('id')
      ..['user_id'] = userId;

    await database.from('info').insert(data);
  }

  // Read semua info milik user
  final stream = Supabase.instance.client
      .from('info')
      .stream(primaryKey: ['id'])
      .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
      .map((data) => data.map((item) => Info.fromMap(item)).toList());

  // Update info
  Future<void> updateInfo(Info info) async {
    await database
        .from('info')
        .update(info.toMap()..remove('user_id'))
        .eq('id', info.id!);
  }

  // Delete info
  Future<void> deleteInfo(int id) async {
    await database.from('info').delete().eq('id', id);
  }
}
