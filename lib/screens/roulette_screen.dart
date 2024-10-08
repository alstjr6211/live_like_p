import 'dart:math';
import 'package:flutter/material.dart';

import '../constant/colors.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with SingleTickerProviderStateMixin {
  List<String> _items = ['1', '2'];
  double _currentAngle = 0.0;
  double _targetAngle = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _selectedItem = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // animation listener
    _controller.addListener(() {
      setState(() {
        _currentAngle = _animation.value;
      });
    });

    // animation state listener
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {

        double finalAngle = _currentAngle % (2 * pi);
        print("Final Angle: $finalAngle radians"); //TODO dibug print

        double sweepAngle = 2 * pi / _items.length;

        int selectedItemIndex = (_items.length - (finalAngle / sweepAngle).floor() - 1) % _items.length;
        print("Selected Item Index: $selectedItemIndex"); // TODO dibug print
        _selectedItem = _items[selectedItemIndex];
        print("Selected Item: $_selectedItem"); // TODO dibug print

        //TODO need modify dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Selected Item'),
            content: Text(_selectedItem),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spinRoulette() {
    if (_controller.isAnimating) return;


    double randomDuration = 5;
    _controller.duration = Duration(seconds: randomDuration.floor());


    final randomSpin = Random().nextDouble() * (2 * pi);
    final spinRounds = (10 + Random().nextDouble() * 30) * 2 * pi;
    final totalSpin = spinRounds + randomSpin;
    _targetAngle = _currentAngle + totalSpin;
    print("Spinning to target angle: $_targetAngle radians"); //TODO debug print

    _animation = Tween<double>(begin: _currentAngle, end: _targetAngle).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.forward(from: 0);
  }




  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    final _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: _screenWidth,
              height: _screenHeight * 0.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _currentAngle,
                    child: CustomPaint(
                      painter: _RoulettePainter(_items),
                      size: Size(_screenWidth, _screenHeight * 0.5),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            //spin button
            ElevatedButton(
              onPressed: spinRoulette,
              child: Text('Spin!'),
            ),
            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                    onTap: () {
                      _editItem(index);
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton( // TODO edit additem & delete item button
                onPressed: _addItem,
                child: Icon(Icons.add),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton(
                onPressed: _deleteItem,
                child: Icon(Icons.remove),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    setState(() {
      _items.add('${_items.length + 1}');
    });
  }
  void _deleteItem() {
    setState(() {
      if (_items.length >= 3) {
        _items.removeAt(_items.length - 1);
      }
    });
  }
  // TODO need modify editItem function
  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final _textController = TextEditingController(text: _items[index]);
        return AlertDialog(
          title: Text('이름 변경'),
          content: TextField(
            controller: _textController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _items[index] = _textController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _RoulettePainter extends CustomPainter {
  final List<String> items;

  _RoulettePainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final sweepAngle = 2 * pi / items.length;
    final colors = [
      rouletteColor_1,
      rouletteColor_2,
      rouletteColor_3,
      rouletteColor_4,
      rouletteColor_5,
      rouletteColor_6,
      rouletteColor_7,
      rouletteColor_8,
      rouletteColor_9,
    ];

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * sweepAngle - pi / 2;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textAngle = startAngle + sweepAngle / 2;
      final textX = center.dx + (radius * 0.7) * cos(textAngle);
      final textY = center.dy + (radius * 0.7) * sin(textAngle);
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
