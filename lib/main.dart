import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'counter_model.dart';
import 'database_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANONKEY'),
  );
  // テーブルが存在するか確認し、なければ作成する
  final dbSetup = DatabaseSetup(Supabase.instance.client);
  await dbSetup.setup();

  runApp(const MyApp());
}

// Supabaseクライアントのインスタンスを取得するためのヘルパー
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'モンスターメッセージ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'モンスターメッセージ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  // Supabaseからカウンターの値を読み込む
  Future<void> _loadCounter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // countersテーブルからIDが1のレコードを取得
      final data =
          await supabase.from('counters').select().eq('id', 1).single();

      setState(() {
        _counter = data['count'] as int;
        _isLoading = false;
      });
    } catch (e) {
      // レコードが存在しない場合は作成
      try {
        await supabase.from('counters').insert({'id': 1, 'count': 0});
        setState(() {
          _counter = 0;
          _isLoading = false;
        });
      } catch (e) {
        print('エラー: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // カウンターをインクリメントしてSupabaseに保存
  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });

    try {
      // Supabaseのカウンター値を更新
      await supabase.from('counters').update({'count': _counter}).eq('id', 1);
    } catch (e) {
      print('エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('ボタンを押した回数:'),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
