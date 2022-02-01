import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Счётчики',
      home: MyHomePage(title: 'Счётчики', storage: CounterStorage()),
    );
  }
}

//стиль кнопок первого счетчика
ButtonStyle _buttonStyle_1 = ElevatedButton.styleFrom(
    primary: const Color(0xFF1081D8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22.0),
    ));

//стиль кнопок второго счетчика
ButtonStyle _buttonStyle_2 = ElevatedButton.styleFrom(
    primary: const Color(0xFF07BA07),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22.0),
    ));

//--------------------------------------------------------------------------------
//МЕТОДЫ ДЛЯ ВТОРОГО СЧЕТЧИКА (работа с файлом)
//--------------------------------------------------------------------------------

//метод получения папки
class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

//метод получения файла
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

//метод чтения содержимого файла
  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // чтение файла
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // при ошибке возвращается 0
      return 0;
    }
  }

//метод записи в файл
  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // запись
    return file.writeAsString('$counter');
  }
}

//-----------------------------------------------------------
//ВИДЖЕТ С СОСТОЯНИЕМ
//-----------------------------------------------------------

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter_1 = 0; //объявление перем. для счетчика №1 и знач. при запуске
  int _counter_2 = 0; //объявление перем. для счетчика №2 и знач. при запуске

  @override
  //загрузка сохраненных значений счетчиков №1 и №2
  void initState() {
    super.initState();
    _loadCounter_1();

    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter_2 = value;
      });
    });
  }
//-----------------------------------------------------------------------------
//МЕТОДЫ ДЛЯ ПЕРВОГО СЧЕТЧИКА в виджете с состоянием
//-----------------------------------------------------------------------------

  //метод загрузки сохраненного знач. счетчика №1
  void _loadCounter_1() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter_1 = (prefs.getInt('counter') ?? 0);
    });
  }

  //метод увелич. знач. счетчика №1
  void _incrementCounter_1() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter_1 = (prefs.getInt('counter') ?? 0) + 1; //увелич.
      prefs.setInt('counter', _counter_1); //сохр.
    });
  }
  //сброс счетчика №1
  void _resetCounter_1() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter_1 = 0; //обнуление
      prefs.setInt('counter', _counter_1); //сохр.
    });
  }

//-----------------------------------------------------------------------------
//МЕТОДЫ ДЛЯ ВТОРОГО СЧЕТЧИКА в виджете с состоянием
//-----------------------------------------------------------------------------
//метод увеличения счетчика №2 и сохранения в файл
  Future<File> _incrementCounter_2() {
    setState(() {
      _counter_2++;
    });
    // запись в файл
    return widget.storage.writeCounter(_counter_2);
  }

//метод обнуления счетчика №2
  Future<File> _resetCounter_2() {
    setState(() {
      _counter_2 = 0; //обнуление
    });
    // запись в файл
    return widget.storage.writeCounter(_counter_2);
  }

//----------------------------------------------------------------------------
//ЭКРАН
//----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //--------------------первый счетчик---------------
            const Text(
              'Счётчик №1',
            ),
            Text(
              '$_counter_1',
              style: Theme.of(context).textTheme.headline4,
            ),
            //---------кнопка увелич. счетчика №1--------------
            ElevatedButton(
              onPressed: _incrementCounter_1,
              child: const Text('shared_preferences'),
              style: _buttonStyle_1,
            ),
            //-----------кнопка сброса счетчика №1-------------
            ElevatedButton(
              onPressed: _resetCounter_1,
              child: const Text('сброс'),
              style: _buttonStyle_1,
            ),

            const SizedBox(height: 60.0),

            //--------------второй счетчик----------------------
            const Text(
              'Счётчик №2',
            ),
            Text(
              '$_counter_2',
              style: Theme.of(context).textTheme.headline4,
            ),
            //--------------кнопка увеличения счетчика №2-------
            ElevatedButton(
              onPressed: _incrementCounter_2,
              style: _buttonStyle_2,
              child: const Text('   file r/w   '),
            ),
            //-------------кнопка сброса счетчика №2------------
            ElevatedButton(
              onPressed: _resetCounter_2,
              style: _buttonStyle_2,
              child: const Text('сброс'),
            )
          ],
        ),
      ),
    );
  }
}

