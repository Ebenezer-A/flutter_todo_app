import 'package:flutter/material.dart';
import 'package:flutter_todo_app/Todo.dart';


void main() async {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Todo App',
      home: TodoList(),
    );
  }
}
