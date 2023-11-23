import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogModel {
  List<dynamic> users = [];
  List<dynamic> posts = [];
  List<dynamic> comments = [];
  dynamic selectedUser;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      posts = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts data');
    }
  }

  Future<void> fetchUser() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      users = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users data');
    }
  }

  List<dynamic> selectedPosts() {
    if (selectedUser == null) {
      return posts;
    } else {
      return posts.where((post) => post['userId'] == selectedUser['id']).toList();
    }
  }

  Future<void> fetchComments() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

    if (response.statusCode == 200) {
      comments = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users data');
    }
  }

  Future<List<dynamic>> fetchCommentsForPost(int postId) async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments?postId=$postId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load comments data');
    }
  }

  Future<void> addPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': selectedUser['id'],
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      print('Post added successfully');
    } else {
      // Failed to add post
      throw Exception('Failed to add post');
    }
  }

  dynamic getUserByPost(dynamic post) {
    if (post != null && post['userId'] != null) {
      return users.firstWhere((user) => user['id'] == post['userId'], orElse: () => null);
    } else {
      return null;
    }
  }
  Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$postId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Post deleted successfully');
    } else {
      print('Failed to delete post');
    }
  }
  }

