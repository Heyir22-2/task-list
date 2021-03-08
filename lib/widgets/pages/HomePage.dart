import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  Icon _getButton() {
    return (_counter >= 3) ? Icon(Icons.remove) : Icon(Icons.add);
  }

  Widget _getText() {
    if (_counter == 0) {
      return Text('Start to tap');
    } else if (_counter == 3) {
      return Text('Go back to 2');
    } else {
      return Text('Go to 3');
    }
  }

  Color _getColor() {
    return (_counter == 3) ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(
                color: _getColor(),
              ),
            ),
            _getText(),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_counter >= 3) ? _decrementCounter : _incrementCounter,
        tooltip: 'Increment',
        child: _getButton(),
      ),
    );
  }
}
