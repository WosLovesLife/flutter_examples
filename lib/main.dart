import 'package:flutter/material.dart';
import 'package:flutter_app/card_flip/FlipCarousel.dart';
import 'SignaturePainter.dart';
import 'LogoApp.dart';
import 'AsyncInFlutter.dart';
import 'IsolateSample.dart';
import 'CustomScrollPhysics.dart';

void main() {
  runApp(new Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Main",
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Examples"),
        ),
        body: new ExampleList(),
      ),
      routes: <String, WidgetBuilder>{
        '/a': (BuildContext context) => new SignaturePainterDemo(),
        '/b': (BuildContext context) => new LogoApp(),
        '/c': (BuildContext context) => new AsyncInFlutter(),
        '/d': (BuildContext context) => new IsolateSample(),
        '/e': (BuildContext context) => new InfinityListView(),
        '/f': (BuildContext context) => new FlipCarousel(),
      },
    );
  }
}

class ExampleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Button("Signature Painter Demo", '/a'),
        new Button("Anim - LogoApp", '/b'),
        new Button("Async In Flutter", '/c'),
        new Button("Isolate Sample", '/d'),
        new Button("Custom ScrollPhysics", '/e'),
        new Button("Flip Carousel", '/f'),
      ],
    );
  }
}

class Button extends StatelessWidget {
  Button(this.text, this.pageName);

  final String text;
  final String pageName;

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 48.0,
      margin: const EdgeInsets.all(16.0),
      child: new RaisedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(pageName);
        },
        child: new Text(this.text),
      ),
    );
  }
}
