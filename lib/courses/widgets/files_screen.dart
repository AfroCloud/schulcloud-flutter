import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file_browser/file_browser.dart';

import '../bloc.dart';
import '../data.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            flexibleSpace: Align(
              alignment: Alignment.bottomCenter,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 4,
                labelColor: Colors.black,
                tabs: <Widget>[
                  Tab(text: 'My files'),
                  Tab(text: 'Course files'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              _UserFilesList(),
              _CourseFilesList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserFilesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FileListHeader(
          icon: Icon(Icons.person_outline, size: 48),
          text: 'These are your personal files.\n'
              'By default, only you can access them, but they '
              'may be shared with others.',
        ),
        Expanded(
          child: FileBrowser(
            owner: Provider.of<MeService>(context).me,
            isEmbedded: true,
          ),
        ),
      ],
    );
  }
}

class _CourseFilesList extends StatelessWidget {
  void _showCourseFiles(BuildContext context, Course course) {
    Navigator.of(context).push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: Provider.of<Bloc>(context).getCourses(),
      builder: (context, snapshot) {
        return ListView(
          children: <Widget>[
            FileListHeader(
                icon: Icon(Icons.school, size: 48),
                text: 'These are the files from courses you are enrolled in. '
                    'Anyone in the course (including teachers) has access to them.'),
            if (!snapshot.hasData) ...[
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator())
            ] else
              for (var course in snapshot.data)
                ListTile(
                  title: Text(course.name),
                  leading: Icon(Icons.folder, color: course.color),
                  onTap: () => _showCourseFiles(context, course),
                ),
          ],
        );
      },
    );
  }
}

class FileListHeader extends StatelessWidget {
  final Widget icon;
  final String text;

  FileListHeader({@required this.icon, @required this.text})
      : assert(icon != null),
        assert(text != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black12,
      height: 100,
      child: Row(
        children: <Widget>[
          icon,
          SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
