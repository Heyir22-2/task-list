import 'package:tasklist/widgets/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:tasklist/widgets/pages/MyTasks.dart';

class TaskList extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyTasks(),
    );
  }
}
