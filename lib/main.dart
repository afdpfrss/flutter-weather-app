import 'package:flutter/material.dart'; // FlutterのUIを作るためのパッケージ
import 'package:http/http.dart' as http; // HTTPリクエストを送るためのパッケージ
import 'dart:convert'; // JSONデータを扱うためのパッケージ

// アプリのエントリーポイント（最初に実行される関数）
void main() {
  runApp(const MyApp());
}

// アプリ全体のルートウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '天気予報アプリ',
      home: WeatherPage(), // 最初に表示する画面
    );
  }
}

// 天気情報を表示する画面
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _controller = TextEditingController(); // 入力された都市名を取得するためのコントローラ
  String _weather = '';         // 天気の結果を表示する文字列
  bool _isLoading = false;      // 通信中にローディングを表示するためのフラグ

  // OpenWeatherMapのAPIキー
  final String apiKey = 'f4016e2854f64b767446f58e8085d75d';

  // 天気情報を取得する非同期関数
  Future<void> fetchWeather(String city) async {
    setState(() {
      _isLoading = true; // 通信開始時にローディングを表示
    });

    // APIのURLを組み立て
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&lang=ja&units=metric';

    try {
      // HTTPリクエストを送信
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 成功時：JSONをパースして必要な情報を抽出
        final data = json.decode(response.body);
        final temp = data['main']['temp']; // 気温
        final description = data['weather'][0]['description']; // 天気の説明
        final name = data['name']; // 都市名

        // 結果を表示用に整形
        setState(() {
          _weather = '$name：$description（${temp.toStringAsFixed(1)}°C）';   // 気温を小数第1位までに整形
        });
      } else {
        // 失敗時：エラーメッセージを表示
        setState(() {
          _weather = '天気情報が取得できませんでした';
        });
      }
    } catch (e) {
      // 通信エラー時の処理
      setState(() {
        _weather = '通信エラー：$e';
      });
    } finally {
      // 通信完了時にローディングを非表示にする
      setState(() {
        _isLoading = false;
      });
    }
  }

  // UIを構築する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天気予報アプリ')), // 上部のバー
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 都市名を入力するテキストフィールド
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: '都市名を入力'),
            ),
            const SizedBox(height: 16),
            // ボタンを押すと天気情報を取得
            ElevatedButton(
              onPressed: () => fetchWeather(_controller.text),
              child: const Text('天気を調べる'),
            ),
            const SizedBox(height: 24),
            // 通信中ならローディング、それ以外は天気情報を表示
            _isLoading
                ? const CircularProgressIndicator() // ローディング
                : Text(
                    _weather,
                    style: const TextStyle(fontSize: 18),
                  ),
          ],
        ),
      ),
    );
  }
}
