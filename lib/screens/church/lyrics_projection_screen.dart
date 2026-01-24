import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/song_model.dart';

class LyricsProjectionScreen extends StatefulWidget {
  final Song song;

  const LyricsProjectionScreen({
    super.key,
    required this.song,
  });

  @override
  State<LyricsProjectionScreen> createState() => _LyricsProjectionScreenState();
}

class _LyricsProjectionScreenState extends State<LyricsProjectionScreen> {
  double _fontSize = 36.0;
  final double _minFontSize = 24.0;
  final double _maxFontSize = 72.0;
  bool _showControls = false;
  final ScrollController _scrollController = ScrollController();

  // Split lyrics into slides
  late List<String> _slides;
  int _currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _parseSlides();
    _enterFullScreen();
  }

  void _parseSlides() {
    // Split lyrics into logical sections/slides
    // Look for blank lines, [Verse], [Chorus], etc.
    final lyrics = widget.song.lyrics;

    // Split by double newlines or section markers
    final sections = lyrics.split(RegExp(r'\n\s*\n|\[.*?\]'));

    _slides = sections
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // If no sections found, split by every 4-6 lines
    if (_slides.length <= 1 && lyrics.isNotEmpty) {
      final lines = lyrics.split('\n').where((l) => l.trim().isNotEmpty).toList();
      _slides = [];
      for (int i = 0; i < lines.length; i += 4) {
        final end = (i + 4 < lines.length) ? i + 4 : lines.length;
        _slides.add(lines.sublist(i, end).join('\n'));
      }
    }

    // Ensure at least one slide
    if (_slides.isEmpty) {
      _slides = [lyrics.isNotEmpty ? lyrics : 'No lyrics available'];
    }
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _exitFullScreen();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlideIndex < _slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
    }
  }

  void _previousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
    }
  }

  void _goToSlide(int index) {
    if (index >= 0 && index < _slides.length) {
      setState(() {
        _currentSlideIndex = index;
        _showControls = false;
      });
    }
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + 4).clamp(_minFontSize, _maxFontSize);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 4).clamp(_minFontSize, _maxFontSize);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _showControls) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _nextSlide();
            } else if (details.primaryVelocity! > 0) {
              _previousSlide();
            }
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _increaseFontSize();
            } else if (details.primaryVelocity! > 0) {
              _decreaseFontSize();
            }
          }
        },
        child: Stack(
          children: [
            // Main lyrics display
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _slides[_currentSlideIndex],
                    key: ValueKey(_currentSlideIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5F5F0), // Cream white
                      height: 1.8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _showControls
                  ? Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Column(
                        children: [
                          // Top bar with title and close button
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.song.title,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Font size controls
                                  IconButton(
                                    icon: const Icon(Icons.text_decrease, color: Colors.white),
                                    onPressed: _decreaseFontSize,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_increase, color: Colors.white),
                                    onPressed: _increaseFontSize,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Slide indicator and navigation
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Slide dots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_slides.length, (index) {
                                    return GestureDetector(
                                      onTap: () => _goToSlide(index),
                                      child: Container(
                                        width: index == _currentSlideIndex ? 24 : 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: index == _currentSlideIndex
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),

                                // Navigation buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _currentSlideIndex > 0 ? _previousSlide : null,
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Previous'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${_currentSlideIndex + 1} / ${_slides.length}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _currentSlideIndex < _slides.length - 1
                                          ? _nextSlide
                                          : null,
                                      icon: const Icon(Icons.arrow_forward),
                                      label: const Text('Next'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Help text
                                Text(
                                  'Swipe left/right for slides, up/down for font size',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Navigation arrows (always visible but subtle)
            if (!_showControls) ...[
              // Left arrow
              if (_currentSlideIndex > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 48,
                      ),
                      onPressed: _previousSlide,
                    ),
                  ),
                ),
              // Right arrow
              if (_currentSlideIndex < _slides.length - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 48,
                      ),
                      onPressed: _nextSlide,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
