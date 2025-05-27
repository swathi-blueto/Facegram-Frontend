import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingIcons extends StatefulWidget {
  const ScrollingIcons({super.key});

  @override
  State<ScrollingIcons> createState() => _ScrollingIconsState();
}

class _ScrollingIconsState extends State<ScrollingIcons> {
  final ScrollController _scrollController = ScrollController();
  late final Timer _timer;

  final List<Map<String, String>> iconData = [
    {
      'name': 'Reels',
      'image':
          'https://cdn-icons-png.flaticon.com/128/11820/11820224.png',
    },
    {
      'name': 'Stories',
      'image':
          'https://cdn-icons-png.flaticon.com/128/3887/3887366.png',
    },
    {
      'name': 'Chat',
      'image':
          'https://cdn-icons-png.flaticon.com/512/134/134914.png',
    },
    {
      'name': 'Live',
      'image':
          'https://cdn-icons-png.flaticon.com/128/12891/12891849.png',
    },
    {
      'name': 'Group',
      'image':
          'https://cdn-icons-png.flaticon.com/128/681/681392.png',
    },
    
  ];

 @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_scrollController.hasClients &&
          _scrollController.position.haveDimensions) {
        double newPosition = _scrollController.offset + 1;
        if (newPosition >= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(newPosition);
        }
      }
    });
  });
}


 @override
void dispose() {
  _timer?.cancel();
  _scrollController.dispose();
  super.dispose();
}


  @override
  
Widget build(BuildContext context) {
  return Container(
    color: Color.fromARGB(255, 242, 240, 240),
    height: 60, 
    padding: const EdgeInsets.symmetric( vertical: 10), 
    child: ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: iconData.length,
      itemBuilder: (context, index) {
        return Container(
         
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey),
            color: Colors.white60
          ),
          child: Row(
            children: [
              Image.network(
                iconData[index]['image']!,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
              Text(
                iconData[index]['name']!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    ),
  );
}

}
