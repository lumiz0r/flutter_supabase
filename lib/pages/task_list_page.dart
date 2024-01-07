import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_supabase/main.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Stream<List<Map<String, dynamic>>> _taskStream;
  final StreamController<void> _refreshController = StreamController<void>();

  @override
  void initState() {
    super.initState();
    _taskStream = supabase.from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', supabase.auth.currentSession!.user.id)
        .order('id', ascending: false);

    _refreshController.stream.listen((_) {
      setState(() {
        _taskStream = supabase.from('tasks')
            .stream(primaryKey: ['id'])
            .eq('user_id', supabase.auth.currentSession!.user.id)
            .order('id', ascending: false);
      });
    });
  }

  @override
  void dispose() {
    _refreshController.close();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _taskStream,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final bool isDone = task['state'] == 'done';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final newState = isDone ? 'pending' : 'done';
                            await supabase.from('tasks').update({'state': newState}).eq('id', task['id']);
                            _refreshController.add(null);
                          },
                          icon: Icon(isDone ? Icons.undo : Icons.check),
                        ),
                        IconButton(
                          onPressed: () async {
                            await supabase.from('tasks').delete().eq('id', task['id']);
                            _refreshController.add(null);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: ((context) {
                          String editedTitle = task['title'];
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Edit Task',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    initialValue: task['title'],
                                    onChanged: (value) {
                                      editedTitle = value;
                                    },
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await supabase.from('tasks').update({'title': editedTitle}).eq('id', task['id']);
                                      _refreshController.add(null);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: ((context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Add Task',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                onFieldSubmitted: (value) async {
                                  final userId = supabase.auth.currentSession!.user.id;
                                  await supabase.from('tasks').insert({
                                    'title': value,
                                    'state': 'pending',
                                    'user_id': userId,
                                  });
                                  _refreshController.add(null);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/account');
                },
                child: const Text('Profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}
