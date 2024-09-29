import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:i_protect/route/app_router.gr.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: Text('Home'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('goto login'),
        onPressed: () {
          context.router.push(LoginRoute());
        },
      ),
    );
  }
}
