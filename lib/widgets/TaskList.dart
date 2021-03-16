import 'package:flutter/material.dart';
import 'package:tasklist/widgets/pages/MyTasks.dart';

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Task List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyTasks(),
    );
  }
}
