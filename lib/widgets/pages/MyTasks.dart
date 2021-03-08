import 'package:flutter/material.dart';
import 'package:tasklist/models/Task.dart';

class MyTasks extends StatefulWidget {
  MyTasks({Key key}) : super(key: key);

  @override
  _MyTasksState createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  List<Task> _tasks = [
    Task('Préparer à manger'),
  ];

  void _addTask() {
    setState(() {
      _tasks.add(Task('Aller manger'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Tasks"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (BuildContext context, int index) {
            final Task task = _tasks[index];

            return Card(
              child: ListTile(
                title: Text(
                  task.title,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
