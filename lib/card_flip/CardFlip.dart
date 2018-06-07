import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/card_flip/card_data.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(new Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flip Carousel',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double scrollPercent = 0.0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Room for status bar
            new Container(
              width: double.infinity,
              height: 20.0,
            ),

            // Cards
            new Expanded(
              child: new CardFlipper(
                demoCards,
                (double p) {
                  setState(() {
                    scrollPercent = p;
                  });
                },
              ),
            ),

            // Bottom bar
            new BottomBar(
              cardCount: demoCards.length,
              scrollPercent: scrollPercent,
            )
          ],
        ),
      );
}

class CardFlipper extends StatefulWidget {
  final List<CardViewModel> demoCards;
  final Function(double scrollPercent) onScroll;

  CardFlipper(this.demoCards, this.onScroll);

  @override
  State<StatefulWidget> createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper> with SingleTickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  @override
  void initState() {
    super.initState();

    finishScrollController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {
          scrollPercent =
              lerpDouble(finishScrollStart, finishScrollEnd, finishScrollController.value);
          if (widget.onScroll != null) {
            widget.onScroll(scrollPercent);
          }
        });
      });
  }

  @override
  void dispose() {
    super.dispose();

    finishScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    final numCards = widget.demoCards.length;
    setState(() {
      scrollPercent = (startDragPercentScroll + (-singleCardDragPercent / numCards))
          .clamp(0.0, 1.0 - (1 / numCards));
      if (widget.onScroll != null) {
        widget.onScroll(scrollPercent);
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final numCards = widget.demoCards.length;

    finishScrollStart = scrollPercent;
    finishScrollEnd = (scrollPercent * numCards).round() / numCards;
    finishScrollController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  List<Widget> _buildCards() {
    final numCards = widget.demoCards.length;
    int index = 0;
    return demoCards
        .map((CardViewModel m) => _buildCard(index++, numCards, scrollPercent, m))
        .toList();
  }

  Widget _buildCard(int cardIndex, int cardCount, double scrollPercent, CardViewModel model) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallaxPercent = scrollPercent - (cardIndex / cardCount);

    return FractionalTranslation(
      translation: new Offset(cardIndex - cardScrollPercent, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Transform(
          transform: _buildCardProjection(cardScrollPercent - cardIndex),
          child: Card(
            model,
            parallaxPercent,
          ),
        ),
      ),
    );
  }

  Matrix4 _buildCardProjection(double scrollPercent) {
    final perspective = 0.002;
    final radius = 1.0;
    final angle = scrollPercent * pi / 8;
    final horizontalTranslation = 0.0;
    Matrix4 projection = new Matrix4.identity()
      ..setEntry(0, 0, 1 / radius)
      ..setEntry(1, 1, 1 / radius)
      ..setEntry(3, 2, -perspective)
      ..setEntry(2, 3, -radius)
      ..setEntry(3, 3, perspective * radius + 1.0);

    final rotationPointMultiplier = angle > 0.0 ? angle / angle.abs() : 1.0;
    print('Angle = $angle');
    projection *= new Matrix4.translationValues(
            horizontalTranslation + (rotationPointMultiplier * 300.0), 0.0, 0.0) *
        new Matrix4.rotationY(angle) *
        new Matrix4.translationValues(0.0, 0.0, radius) *
        new Matrix4.translationValues(-rotationPointMultiplier * 300.0, 0.0, 0.0);

    return projection;
  }
}

class Card extends StatelessWidget {
  final CardViewModel cardViewModel;
  final double parallaxPercent;

  Card(this.cardViewModel, this.parallaxPercent);

  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ClipRRect(
          borderRadius: new BorderRadius.circular(10.0),
          child: FractionalTranslation(
            translation: new Offset(parallaxPercent * 2.0, 0.0),
            child: OverflowBox(
              maxWidth: double.infinity,
              child: new Image.asset(
                cardViewModel.backdropAssetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: new Text(
                cardViewModel.address.toUpperCase(),
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            new Expanded(child: Container()),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  '${cardViewModel.minHeightInFeet} - ${cardViewModel.maxHeightInFeet}',
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 130.0,
                    letterSpacing: -5.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 30.0),
                  child: new Text(
                    'FT',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: new Text(
                    '${cardViewModel.tempInDegrees}˚',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            new Expanded(child: Container()),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                child: new Container(
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(30.0),
                    border: new Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          cardViewModel.weatherType,
                          style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Icon(
                            Icons.wb_cloudy,
                            color: Colors.white,
                          ),
                        ),
                        new Text(
                          '${cardViewModel.windSpeedInMph}mph ${cardViewModel.cardinalDirection}',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class BottomBar extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  BottomBar({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
              child: Center(
            child: new Icon(
              Icons.settings,
              color: Colors.white,
            ),
          )),
          new Expanded(
            child: new Container(
              width: double.infinity,
              height: 5.0,
              child: new ScrollIndicator(
                cardCount: cardCount,
                scrollPercent: scrollPercent,
              ),
            ),
          ),
          new Expanded(
              child: Center(
            child: new Icon(
              Icons.add,
              color: Colors.white,
            ),
          )),
        ],
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  ScrollIndicator({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new ScrollIndicatorPainter(
        cardCount: cardCount,
        scrollPercent: scrollPercent,
      ),
      child: new Container(),
    );
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  final int cardCount;
  final double scrollPercent;
  final Paint trackPaint;
  final Paint thumbPaint;

  ScrollIndicatorPainter({this.cardCount, this.scrollPercent})
      : trackPaint = new Paint()
          ..color = const Color(0xFF444444)
          ..style = PaintingStyle.fill,
        thumbPaint = new Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      new RRect.fromRectAndCorners(
        new Rect.fromLTWH(
          0.0,
          0.0,
          size.width,
          size.height,
        ),
        topLeft: new Radius.circular(3.0),
        topRight: new Radius.circular(3.0),
        bottomLeft: new Radius.circular(3.0),
        bottomRight: new Radius.circular(3.0),
      ),
      trackPaint,
    );

    final thumbWidth = size.width / cardCount;
    final thumbLeft = scrollPercent * size.width;

    canvas.drawRRect(
      new RRect.fromRectAndCorners(
        new Rect.fromLTWH(
          thumbLeft,
          0.0,
          thumbWidth,
          size.height,
        ),
        topLeft: new Radius.circular(3.0),
        topRight: new Radius.circular(3.0),
        bottomLeft: new Radius.circular(3.0),
        bottomRight: new Radius.circular(3.0),
      ),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
