import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tasklist/models/Task.dart';

import '../../models/Task.dart';

class MyTasks extends StatefulWidget {
  MyTasks({Key key}) : super(key: key);

  @override
  _MyTasksState createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  bool _openForm;
  bool _isEditing;
  Task _currentTask;
  List<Task> _tasks;
  Dio dio;
  String endpoint;
  Response response;

  _MyTasksState() {
    BaseOptions options = new BaseOptions(
      baseUrl: endpoint,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    dio = new Dio(options);
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final GlobalKey _scaffoldKey = GlobalKey();

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  void initState() {
    setState(() {
      _openForm = false;
      _isEditing = false;
      _tasks = [];
      dio.options.baseUrl = 'https://jsonplaceholder.typicode.com';
      _getTasks();
    });

    _read(null);

    super.initState();
  }

  void _getTasks() async {
    try {
      response = await dio.get('/posts');
      setState(() {
        response.data.forEach((task) => _tasks.insert(0, Task.fromJson(task)));
      });
    } catch (e) {
      print(e);
    }
  }

  void _saveTask(String content) {
    setState(() {
      if (!_isEditing) {
        _addTask(content);
        _showNotification('Task added');
      } else {
        _currentTask.content = content;
        _update(_currentTask);
        _showNotification('Task updated');
      }
      _contentController.text = "";
      _isEditing = false;
      _openForm = false;
    });
  }

  void _showAlertDialog() {
    Widget okButton = TextButton(
        child: Text("Yes, delete !"),
        onPressed: () {
          _deleteTask();
        });

    Widget cancelButton = TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        });

    AlertDialog alert = AlertDialog(
      title: Text("Task deletion"),
      content: Text("Are you sure ?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showNotification(String message) {
    var snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );

    _scaffoldMessengerKey.currentState.showSnackBar(snackbar);
  }

  void _addTask(String content) {
    setState(() {
      //_tasks.insert(0, Task(content));
      _create(Task(content));
    });
  }

  void _onEditTask(Task task) {
    setState(() {
      _currentTask = task;
      _isEditing = true;
    });
    _openForm = true;
    _contentController.text = _currentTask.content;
  }

  void _onCompletedChange(bool value) {
    setState(() {
      _currentTask.completed = value;
    });
  }

  void _onDeleteTask() {
    setState(() {
      //_tasks.remove(_currentTask);
      _showAlertDialog();
    });
    _openForm = false;
  }

  void _deleteTask() {
    _delete(_currentTask.id);
    _showNotification('Task deleted');
  }

  void _openCloseForm() {
    setState(() {
      (_openForm) ? _openForm = false : _openForm = true;
      _isEditing = false;
      _currentTask = Task("");
      _contentController.text = _currentTask.content;
    });
  }

  Future<void> _create(Task task) async {
    try {
      Response response = await dio.request(
        '/',
        data: task.toJson(),
        options: Options(
            contentType: 'application/json; charset=UTF-8', method: 'POST'),
      );
      if (response.statusCode == 201) {
        await _read(null);
        setState(() {
          _tasks.insert(0, Task.fromJson(response.data));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _read(int id) async {
    Response response;
    try {
      if (id != null) {
        response = await dio.request("/" + id.toString());
      } else {
        response = await dio.request("/");
      }

      if (response.statusCode == 200) {
        if (id != null) {
          var task = Task.fromJson(response.data);
          setState(() {
            _tasks.add(task);
          });
        } else {}
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _update(Task task) {}

  Future<void> _delete(int id) {}

  Widget _taskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final Task task = _tasks[index];

        return Card(
          child: ListTile(
            onTap: () => _onEditTask(task),
            onLongPress: () => _onDeleteTask(),
            title: Text(
              task.content,
            ),
          ),
        );
      },
    );
  }

  Widget _completed() {}

  Widget _taskForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _contentController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a task';
                }
                return null;
              },
              onSaved: (value) => _saveTask(value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                (_isEditing && _openForm)
                    ? ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        ),
                        onPressed: () => _onDeleteTask(),
                        child: Center(
                          child: Icon(Icons.delete),
                        ),
                      )
                    : Container(),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _formKey.currentState.reset();
                    }
                  },
                  child: Center(
                    child: Icon(Icons.check),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Tasks"),
        ),
        body: Column(
          children: [
            (_openForm) ? _taskForm(context) : Container(),
            Expanded(
              child: (_tasks.length > 0)
                  ? _taskList()
                  : Center(
                      child: Text('No task at the moment'),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openCloseForm,
          tooltip: (_openForm) ? 'Close' : 'Add',
          child: (_openForm) ? Icon(Icons.close) : Icon(Icons.add),
        ),
      ),
    );
  }
}
