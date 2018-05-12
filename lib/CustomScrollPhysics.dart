import 'package:flutter/material.dart';
import 'dart:math' as Math;

/// refer: https://www.youtube.com/watch?v=f_aN4aN3Xdc&lc=z22fulxh0lbfhlreaacdp434xzuyzi0b1i2pgz3es1lw03c010c.1526013122661202
class InfinityListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _InfinityListViewState();
}

class _InfinityListViewState extends State<InfinityListView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) =>
      new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
        new Material(
          color: Colors.black38,
          child: new Center(
            child: new ConstrainedBox(
              constraints: new BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: new ListView.builder(
                  physics: new CustomScrollPhysics(),
                  itemExtent: 250.0,
                  itemBuilder: (BuildContext context, int index) =>
                  new Container(
                    margin: const EdgeInsets.all(4.0),
                    child: new Material(
                      elevation: 4.0,
                      borderRadius: new BorderRadius.circular(5.0),
                      color: index % 2 == 0 ? Colors.cyan : Colors.deepOrange,
                      child: new Center(
                        child: new Text(index.toString()),
                      ),
                    ),
                  ),
              ),
            ),
          ),
        ),
      );
}

class CustomSimulation extends Simulation {
  final double initPosition;
  final double velocity;

  CustomSimulation(this.initPosition, this.velocity);

  @override
  double x(double time) => Math.max(Math.min(initPosition, 0.0), initPosition + velocity * time);

  @override
  double dx(double time) => velocity;

  @override
  bool isDone(double time) => false;
}

class CustomScrollPhysics extends ScrollPhysics {
  @override
  ScrollPhysics applyTo(ScrollPhysics ancestor) => new CustomScrollPhysics();

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) =>
      new CustomSimulation(position.pixels, velocity);
}

void main() =>
    runApp(new MaterialApp(
      title: 'Mei Zi',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new InfinityListView(),
    ));