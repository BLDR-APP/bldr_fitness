import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class VideoBackgroundWidget extends StatefulWidget {
  final Widget child;

  const VideoBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<VideoBackgroundWidget> createState() => _VideoBackgroundWidgetState();
}

class _VideoBackgroundWidgetState extends State<VideoBackgroundWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4'),
      );

      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0);
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      // Fallback to static background if video fails
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video background or fallback
        Positioned.fill(
          child: _isVideoInitialized && _videoController != null
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryBlack,
                        AppTheme.surfaceDark,
                        AppTheme.primaryBlack,
                      ],
                    ),
                  ),
                ),
        ),
        // Dark overlay for text readability
        Positioned.fill(
          child: Container(
            color: AppTheme.primaryBlack.withValues(alpha: 0.6),
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}
