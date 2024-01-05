import 'package:flutter/material.dart';
import 'package:flutter_supabase/main.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});
  @override 
  Widget build(BuildContext context) {
    final _taskStream = supabase.from('tasks').stream(primaryKey: ['userId']).eq('userId', supabase.auth.currentUser!.id).order('id', ascending: false).execute();

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
                            },
                            icon: Icon(isDone ? Icons.undo : Icons.check),
                          ),
                          IconButton(
                            onPressed: () async {
                              await supabase.from('tasks').delete().eq('id', task['id']);
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
                                    final userId = supabase.auth.currentUser!.id;
                                    await supabase.from('tasks').insert({
                                      'title': value,
                                      'state': 'pending',
                                      'userId': userId,
                                    });
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
                  backgroundColor: Colors.purple,
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