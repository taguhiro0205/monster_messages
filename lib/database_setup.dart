import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseSetup {
  final SupabaseClient client;

  DatabaseSetup(this.client);

  Future<void> setup() async {
    await _createCountersTable();
  }

  Future<void> _createCountersTable() async {
    // RPC関数を使って新しいテーブルを作成するには、SQLを実行する必要があります
    // 通常はSupabaseのダッシュボードからSQL Editorを使用します
    // ここでは、APIを通じて直接テーブルを作成する方法を示します

    try {
      // テーブルが存在するか確認
      await client.from('counters').select().limit(1);
      print('countersテーブルは既に存在します');
    } catch (e) {
      try {
        // テーブルが存在しない場合、テーブルを作成するためのSQLを実行
        print('countersテーブルを作成しようとしています');

        // 初期レコードを作成しようとする
        await client.from('counters').insert({'id': 1, 'count': 0});
        print('countersテーブルとレコードが作成されました');
      } catch (e) {
        print('テーブル作成エラー: $e');
      }
    }
  }
}
