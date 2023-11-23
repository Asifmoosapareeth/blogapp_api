import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Service/blog_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  BlogModel blogModel=BlogModel();
  final TextEditingController titleController = TextEditingController();

  final TextEditingController bodyController = TextEditingController();

  dynamic selectedUser;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await blogModel.fetchUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0),
        child: Card(elevation: 5,
          child: Padding(padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Body', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),

                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter body',
                    border: OutlineInputBorder(),
                  ),
                ),
                DropdownButton<dynamic>(
                  value: selectedUser,
                  onChanged: (dynamic newValue) {
                    setState(() {
                      selectedUser = newValue;
                    });
                  },
                  items: [
                    const DropdownMenuItem<dynamic>(
                      value: null,
                      child: Text('Select a User'),
                    ),
                    for (dynamic user in blogModel.users)
                      DropdownMenuItem<dynamic>(
                        value: user,
                        child: Text(user['name']),
                      ),
                  ],
                ),



              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          final title = titleController.text.trim();
          final body = bodyController.text.trim();
          if (title.isEmpty || body.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text('Add Title and Body'),
              ),
            );
            return;
          }
          if(selectedUser==null){
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Select a user')));
            return;
          }

          await addPost(titleController.text, bodyController.text, context);
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> addPost(String title, String body, BuildContext context) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'New post added successfully',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to add post',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
