import 'package:flutter/material.dart';

class DoubleCurvedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        ClipPath(
          clipper: CurvedClipperBottom(),
          child: Container(
            height: 450, 
            color: Colors.blue[400],
          ),
        ),
        
        ClipPath(
          clipper: CurvedClipperTop(),
          child: Container(
            height: 500, 
            color:  Color.fromRGBO(11, 88, 216, 1),
          ),
        ),
      ],
    );
  }
}


class CurvedClipperBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.5); 
    var cp1 = Offset(size.width / 4, size.height * 0.6);
    var ep1 = Offset(size.width / 2, size.height * 0.45);
    var cp2 = Offset(size.width * 3 / 4, size.height * 0.3);
    var ep2 = Offset(size.width, size.height * 0.45);
    path.quadraticBezierTo(cp1.dx, cp1.dy, ep1.dx, ep1.dy);
    path.quadraticBezierTo(cp2.dx, cp2.dy, ep2.dx, ep2.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class CurvedClipperTop extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.35); 
    var cp1 = Offset(size.width / 4, size.height * 0.5);
    var ep1 = Offset(size.width / 2, size.height * 0.35);
    var cp2 = Offset(size.width * 3 / 4, size.height * 0.2);
    var ep2 = Offset(size.width, size.height * 0.35);
    path.quadraticBezierTo(cp1.dx, cp1.dy, ep1.dx, ep1.dy);
    path.quadraticBezierTo(cp2.dx, cp2.dy, ep2.dx, ep2.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
