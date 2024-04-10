import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class TodoItem {
  final int id;
  final String name;
  final bool isComplete;

  TodoItem({required this.id, required this.name, required this.isComplete});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      name: json['name'],
      isComplete: json['isComplete'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<TodoItem>> futureTodoItems;

  @override
  void initState() {
    super.initState();
    futureTodoItems = fetchTodoItems();
  }

  Future<List<TodoItem>> fetchTodoItems() async {
    final response = await http.get(Uri.parse('http://localhost:5272/api/Todo'));
    if (response.statusCode == 200) {
      Iterable todoItems = jsonDecode(response.body);
      return todoItems.map((item) => TodoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load todo items');
    }
  }

  Future<void> addTodoItem(String name) async {
    final response = await http.post(
      Uri.parse('http://localhost:5272/api/Todo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'name': name, 'isComplete': false}),
    );

    if (response.statusCode == 201) {
      // Refresh the list after adding a new item
      setState(() {
        futureTodoItems = fetchTodoItems();
      });
    } else {
      throw Exception('Failed to add todo item');
    }
  }

  Future<void> updateTodoItem(int id, bool isComplete) async {
    final response = await http.put(
      Uri.parse('http://localhost:5272/api/Todo/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'isComplete': isComplete}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update todo item');
    }
  }

  Future<void> deleteTodoItem(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:5272/api/Todo/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Center(
        child: FutureBuilder<List<TodoItem>>(
          future: futureTodoItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No Todo Items Found');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final todoItem = snapshot.data![index];
                  return ListTile(
                    title: Text(todoItem.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            updateTodoItem(todoItem.id, !todoItem.isComplete);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm Deletion'),
                                  content: Text('Do you want to delete this item?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        deleteTodoItem(todoItem.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Yes'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('No'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController _textFieldController = TextEditingController();
              return AlertDialog(
                title: Text('Add Todo Item'),
                content: TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: 'Enter item name'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      addTodoItem(_textFieldController.text);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}