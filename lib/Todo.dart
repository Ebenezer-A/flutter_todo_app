import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<Todo> _todos = [];

   @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    var response = await http.get(Uri.parse('YOUR_API_URL'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _todos = data.map((item) => Todo.fromJson(item)).toList();
      });
    }
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';

        return AlertDialog(
          title: Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                var response = await http.post(
                  Uri.parse('YOUR_API_URL'),
                  body: jsonEncode({'title': title, 'description': description}),
                  headers: {'Content-Type': 'application/json'},
                );
                if (response.statusCode == 201) {
                  _loadTodos();
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = todo.title;
        String description = todo.description;

        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: TextEditingController(text: title),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: description),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                var response = await http.put(
                  Uri.parse('YOUR_API_URL/${todo.id}'),
                  body: jsonEncode({'title': title, 'description': description}),
                  headers: {'Content-Type': 'application/json'},
                );
                if (response.statusCode == 200) {
                  _loadTodos();
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(Todo todo) async {
    var response = await http.delete(Uri.parse('YOUR_API_URL/${todo.id}'));
    if (response.statusCode == 204) {
      _loadTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_todos == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_todos[index].title),
            subtitle: Text(_todos[index].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editTodo(_todos[index]),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTodo(_todos[index]),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Todo {
  final int id;
  final String title;
  final String description;

  Todo({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

}