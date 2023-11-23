import 'package:flutter/material.dart';
import '../Service/blog_service.dart';
import 'blogadd_screen.dart';
import 'blogview_screen.dart';

class BlogHomeScreen extends StatefulWidget {
  const BlogHomeScreen({super.key});

  @override
  BlogHomeScreenState createState() => BlogHomeScreenState();
}

class BlogHomeScreenState extends State<BlogHomeScreen> {
  BlogModel blogModel = BlogModel();

  @override
  void initState() {
    super.initState();
    _fetchDataAndUser();
  }

  Future<void> _fetchDataAndUser() async {
    await blogModel.fetchUser();
    await _fetchData();
    setState(() {});
  }

  Future<void> _fetchData() async {
    await blogModel.fetchData();
  }

  Future<void> _refreshData() async {
    await _fetchDataAndUser();
    setState(() {});
  }

  Future<void> _deletePost(int postId) async {
    try {
      await blogModel.deletePost(postId);

      int index = blogModel.posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        setState(() {
          blogModel.posts.removeAt(index);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Post deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete post'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Posts'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DropdownButton<Map<String, dynamic>>(
            value: blogModel.selectedUser,
            onChanged: (Map<String, dynamic>? newValue) async {
              setState(() {
                blogModel.selectedUser = newValue;
              });
              await blogModel.fetchData();
            },
            items: [
              DropdownMenuItem<Map<String, dynamic>>(
                value: null,
                child: Text('All Users'),
              ),
              for (Map<String, dynamic> user in blogModel.users)
                DropdownMenuItem<Map<String, dynamic>>(
                  value: user,
                  child: Text(user['name']),
                ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                itemCount: blogModel.selectedPosts().length,
                itemBuilder: (context, index) {
                  final post = blogModel.selectedPosts()[index];
                  return Card(
                    color: Colors.grey.shade200,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(post['title']),
                      subtitle: Text(post['body']),
                      trailing: IconButton(
                        onPressed: () async {
                          await _deletePost(post['id']);
                        },
                        icon: Icon(Icons.delete),
                      ),
                      onTap: () async {
                        final postId = post['id'];
                        final comments = await blogModel.fetchCommentsForPost(
                            postId);
                        dynamic userToSend = blogModel.getUserByPost(post);
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                ViewBlog(
                                  user: userToSend,
                                  post: post,
                                  comments: comments,
                                )));
                      },
                    ),

                  );
                }
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _refreshData();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
