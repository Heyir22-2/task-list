import 'package:flutter/material.dart';
import 'package:tasklist/models/Task.dart';

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
    });
    super.initState();
  }

  void _saveTask(String content) {
    setState(() {
      if (!_isEditing) {
        _addTask(content);
      } else {
        _currentTask.content = content;
      }
      _contentController.text = "";
      _isEditing = false;
      _openForm = false;

      _showConfirmation();
    });
  }

  void _showConfirmation() {
    // if (_rootScaffoldMessengerKey.currentState != null)
    //   _rootScaffoldMessengerKey.currentState.showSnackBar(snackbar);

    var message = (_isEditing) ? 'task updated !' : 'task added !';

    var snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    //ScaffoldMessenger.of(context).showSnackBar(snackbar);
    //ScaffoldMessenger(key: _scaffoldMessengerKey, child: snackbar);
    _scaffoldMessengerKey.currentState.showSnackBar(snackbar);
  }

  void _addTask(String content) {
    setState(() {
      _tasks.insert(0, Task(content));
    });
  }

  void _onEditTask(Task task) {
    setState(() {
      _currentTask = task;
      _isEditing = true;
    });
    _openCloseForm();
  }

  void _openCloseForm() {
    setState(() {
      if (_isEditing) {
        _openForm = true;
      } else {
        (_openForm) ? _openForm = false : _openForm = true;
        _currentTask = Task("");
      }

      _contentController.text = _currentTask.content;
    });
  }

  Widget _taskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final Task task = _tasks[index];

        return Card(
          child: ListTile(
            onTap: () => _onEditTask(task),
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
              child: _taskList(),
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
