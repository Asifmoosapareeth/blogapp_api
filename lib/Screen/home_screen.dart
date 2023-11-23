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
  BlogModel blogModel=BlogModel();
  @override
  void initState() {
    super.initState();
    blogModel.fetchData();
    blogModel.fetchUser();
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
          DropdownButton<dynamic>(
            value: blogModel.selectedUser,
            onChanged: (dynamic newValue) async {
              setState(() {
                blogModel.selectedUser = newValue;
              });
              await blogModel.fetchData();
            },
            items: [
              DropdownMenuItem<dynamic>(
                value: null,
                child: Text('All Users'),
              ),
              for (dynamic user in blogModel.users)
                DropdownMenuItem<dynamic>(
                  value: user,
                  child: Text(user['name']),
                ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: blogModel.fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
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
                            final comments = await blogModel.fetchCommentsForPost(postId);
                            dynamic userToSend = blogModel.getUserByPost(post);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewBlog(
                              user: userToSend,
                              post: post,
                              comments: comments,
                            )));
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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


  Future<void> _deletePost(int postId) async {
    try {
      await blogModel.deletePost(postId);
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
    } finally {
      setState(() {
        blogModel.fetchData();
      });
    }
  }

}
