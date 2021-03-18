import 'package:flutter/material.dart';
import 'package:tasklist/models/Task.dart';
import 'package:dio/dio.dart';

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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  void initState() {
    setState(() {
      _openForm = false;
      _isEditing = false;
      _tasks = [];
      dio = Dio();
      dio.options.baseUrl = "https://jsonplaceholder.typicode.com";
      _read();
    });
    super.initState();
  }

  void _showAlertDialog(Task task) {
    Widget okButton = TextButton(
        child: Text("Yes, delete !"),
        onPressed: () {
          Navigator.of(context).pop();
          _delete(task);
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

  void _saveTask(String content) {
    setState(() {
      if (!_isEditing) {
        _addTask(content);
        _showConfirmation('Task added');
      } else {
        _currentTask.content = content;
        _showConfirmation('Task updated');
      }
      _contentController.text = "";
      _isEditing = false;
      _openForm = false;
    });
  }

  void _showConfirmation(String message) {
    var snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );

    _scaffoldMessengerKey.currentState.showSnackBar(snackbar);
  }

  void _addTask(String content) {
    setState(() {
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
    _update(_currentTask);
  }

  void _onDeleteTask(task) {
    setState(() {
      _showAlertDialog(task);
    });
    _openForm = false;
  }

  void _openCloseForm() {
    setState(() {
      (_openForm) ? _openForm = false : _openForm = true;
      _isEditing = false;
      _currentTask = Task("");
      _contentController.text = _currentTask.content;
    });
  }

  //create task
  Future<void> _create(Task task) async {
    try {
      Response response = await dio.post("/posts", data: task.toJson());
      if (response.statusCode == 201) {
        await _read();
        setState(() {
          _tasks.insert(0, Task.fromJson(response.data));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // get les tasks
  Future<void> _read() async {
    try {
      Response response = await dio.get("/posts");
      setState(() {
        for (var aTask in response.data) {
          _tasks.insert(0, Task.fromJson(aTask));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _update(Task task) async {
    try {
      Response response =
          await dio.put("/posts/" + task.id.toString(), data: task.toJson());
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _delete(Task task) async {
    try {
      Response response = await dio.delete("/posts/" + task.id.toString());
      setState(() {
        _tasks.remove(task);
      });
      print(task.content.toString());

      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  Widget _taskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final Task task = _tasks[index];

        return Card(
          child: ListTile(
            onTap: () => _onEditTask(task),
            onLongPress: () => _onDeleteTask(task),
            title: Text(
              task.content,
            ),
          ),
        );
      },
    );
  }

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
                        onPressed: () => _onDeleteTask(_currentTask),
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
