import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';

/// 영수증 이미지 뷰어 (전체 화면)
class ReceiptImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ReceiptImageViewer({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<ReceiptImageViewer> createState() => _ReceiptImageViewerState();
}

class _ReceiptImageViewerState extends State<ReceiptImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                _buildImagePageView(),
                if (widget.imagePaths.length > 1) _buildPageIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(color: Colors.black.withAlpha(230)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(191),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.imagePaths.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePageView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imagePaths.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withAlpha(127),
            ),
          ),
        ),
      ),
    );
  }
}
