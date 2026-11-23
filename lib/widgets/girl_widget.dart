import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class GirlWidget extends StatelessWidget {
  final String message;
  const GirlWidget({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModelViewer(
          src: "assets/models/Anime-Girl.glb",
          alt: "AI Girl",
          autoRotate: true,
          cameraControls: true,
          autoPlay: true,
        ),
        Positioned(
          top: 10, left: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
            child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
