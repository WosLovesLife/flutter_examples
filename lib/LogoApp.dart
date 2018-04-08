import 'package:flutter/material.dart';

class LogoApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _LogoAppState();
  }

}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 2000));

    CurvedAnimation curvedAnimation = new CurvedAnimation(
        parent: _controller, curve: Curves.fastOutSlowIn);

    _animation =
    new Tween<double>(begin: 0.0, end: 300.0).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });


    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        width: _animation.value,
        height: _animation.value,
        child: new FlutterLogo(),
      ),
    );
  }
}
