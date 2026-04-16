import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/hairstyle_model.dart';
import '../services/api_service.dart';
import '../services/barber_provider.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;
  bool _isCapturing = false;
  bool _showOverlay = true;
  bool _isSendingToBackend = false;

  String? _capturedImagePath;
  String? _backendMessage;
  String? _processedImageUrl;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late final AnimationController _overlayController;
  late final Animation<double> _overlayAnim;

  @override
  void initState() {
    super.initState();

    ApiService.checkHealth().then((ok) {
      debugPrint('Backend conectado: $ok');
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    _overlayAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: Curves.easeInOut,
      ),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isNotEmpty) {
        final frontCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
        await _setupCamera(frontCamera);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (!mounted) return;
      setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    await _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera setup error: $e');
      if (!mounted) return;
      setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });

    final camera = _isFrontCamera
        ? _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          )
        : _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.last,
          );

    await _setupCamera(camera);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final photo = await _controller!.takePicture();

      if (!mounted) return;

      setState(() {
        _capturedImagePath = photo.path;
        _isCapturing = false;
      });

      context.read<BarberProvider>().setCapturedImage(photo.path);
      await _sendPreviewToBackend(photo.path);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCapturing = false);
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (photo == null || !mounted) return;

    setState(() => _capturedImagePath = photo.path);
    context.read<BarberProvider>().setCapturedImage(photo.path);
    await _sendPreviewToBackend(photo.path);
  }

  Future<void> _sendPreviewToBackend(String imagePath) async {
    final provider = context.read<BarberProvider>();
    final hairstyle = provider.selectedHairstyle;

    if (hairstyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona un corte'),
        ),
      );
      return;
    }

    setState(() {
      _isSendingToBackend = true;
      _backendMessage = null;
    });

    provider.setProcessing(true);

    try {
      final response = await ApiService.generatePreview(
        imagePath: imagePath,
        hairstyleId: hairstyle.id,
        hairstyleName: hairstyle.name,
      );

      if (!mounted) return;

      setState(() {
        _backendMessage = response.message;
        _processedImageUrl = response.previewImageUrl != null
            ? ApiService.buildFileUrl(response.previewImageUrl!)
            : null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Backend: ${response.message} · Corte: ${response.hairstyleName ?? hairstyle.name}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _backendMessage = 'Error enviando al backend';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingToBackend = false;
        });
      }
      provider.setProcessing(false);
    }
  }

  void _retake() {
    setState(() {
      _capturedImagePath = null;
      _processedImageUrl = null;
      _backendMessage = null;
    });

    context.read<BarberProvider>().clearCapturedImage();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarberProvider>();
    final hairstyle = provider.selectedHairstyle;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_capturedImagePath != null)
            _buildResultView(hairstyle, provider)
          else
            _buildCameraView(hairstyle, provider),

          _buildTopBar(context, hairstyle),

          if (_capturedImagePath == null)
            _buildCameraControls(context, hairstyle)
          else
            _buildResultControls(context, hairstyle, provider),
        ],
      ),
    );
  }

  Widget _buildCameraView(HairstyleModel? hairstyle, BarberProvider provider) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isCameraInitialized && _controller != null)
          Transform(
            alignment: Alignment.center,
            transform: _isFrontCamera
                ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
                : Matrix4.identity(),
            child: CameraPreview(_controller!),
          )
        else
          _buildCameraPlaceholder(),

        Center(
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: 220,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(120),
                  border: Border.all(
                    color: const Color(0xFFD4A853).withOpacity(0.7),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (hairstyle != null && _showOverlay)
                      _buildHairOverlay(hairstyle, provider),
                  ],
                ),
              ),
            ),
          ),
        ),

        CustomPaint(
          painter: _GridPainter(),
          size: Size.infinite,
        ),

        Positioned(
          bottom: 160,
          left: 0,
          right: 0,
          child: Text(
            hairstyle != null
                ? 'Centra tu rostro dentro del óvalo'
                : 'Selecciona un corte para visualizarlo',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHairOverlay(HairstyleModel hairstyle, BarberProvider provider) {
    return FadeTransition(
      opacity: _overlayAnim,
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: SizedBox(
          width: 200,
          height: 80,
          child: CustomPaint(
            painter: _HairstyleOverlayPainter(
              hairstyle: hairstyle,
              opacity: provider.overlayOpacity,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: const Color(0xFF111111),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4A853).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Color(0xFFD4A853),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cámara no disponible',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: const Color(0xFFF5F0E8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usa "Seleccionar foto" para visualizar\nel corte sobre tu foto',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(HairstyleModel? hairstyle, BarberProvider provider) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_processedImageUrl != null)
          Image.network(
            _processedImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _capturedImagePath != null
                ? Image.file(
                    File(_capturedImagePath!),
                    fit: BoxFit.cover,
                  )
                : const SizedBox.shrink(),
          )
        else if (_capturedImagePath != null)
          Image.file(
            File(_capturedImagePath!),
            fit: BoxFit.cover,
          ),

        if (hairstyle != null && _showOverlay)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showOverlay ? provider.overlayOpacity : 0,
              duration: const Duration(milliseconds: 300),
              child: _buildResultOverlay(hairstyle, provider),
            ),
          ),

        if (_isSendingToBackend)
          Container(
            color: Colors.black.withOpacity(0.45),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildResultOverlay(
    HairstyleModel hairstyle,
    BarberProvider provider,
  ) {
    return Stack(
      children: [
        CustomPaint(
          painter: _ResultOverlayPainter(
            hairstyle: hairstyle,
            opacity: provider.overlayOpacity,
          ),
          size: Size.infinite,
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, HairstyleModel? hairstyle) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 8,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            if (Navigator.canPop(context))
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            const Spacer(),
            if (hairstyle != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4A853).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.content_cut,
                      color: Color(0xFFD4A853),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hairstyle.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        color: const Color(0xFFD4A853),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            if (hairstyle != null)
              IconButton(
                icon: Icon(
                  _showOverlay ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _showOverlay = !_showOverlay);
                  if (_showOverlay) {
                    _overlayController.forward();
                  } else {
                    _overlayController.reverse();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraControls(BuildContext context, HairstyleModel? hairstyle) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.85),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hairstyle != null) _buildHairstyleSlider(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galería',
                  onTap: _pickFromGallery,
                ),
                GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD4A853),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A853).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0D0D0D),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.camera,
                            color: Color(0xFF0D0D0D),
                            size: 32,
                          ),
                  ),
                ),
                _controlButton(
                  icon: Icons.flip_camera_android_rounded,
                  label: 'Voltear',
                  onTap: _toggleCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstyleSlider(BuildContext context) {
    final provider = context.watch<BarberProvider>();
    final hairstyles = BarberData.hairstyles;

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.opacity, color: Color(0xFFD4A853), size: 16),
            Expanded(
              child: Slider(
                value: provider.overlayOpacity,
                min: 0.3,
                max: 1.0,
                activeColor: const Color(0xFFD4A853),
                inactiveColor: Colors.white.withOpacity(0.2),
                onChanged: (v) => provider.setOverlayOpacity(v),
              ),
            ),
            Text(
              'Intensidad',
              style: GoogleFonts.lato(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hairstyles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final h = hairstyles[i];
              final isSelected = provider.selectedHairstyle?.id == h.id;

              return GestureDetector(
                onTap: () => provider.selectHairstyle(h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4A853)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          h.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF333333),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF666666),
                              size: 20,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            color: const Color(0xFFD4A853).withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultControls(
    BuildContext context,
    HairstyleModel? hairstyle,
    BarberProvider provider,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 20,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hairstyle != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4A853).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Image.network(
                          hairstyle.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF2A2A2A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hairstyle.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF5F0E8),
                            ),
                          ),
                          Text(
                            hairstyle.description,
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: const Color(0xFF888888),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '\$${hairstyle.price.toStringAsFixed(0)}',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: const Color(0xFFD4A853),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${hairstyle.duration} min',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: const Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Retomar',
                    icon: Icons.refresh_rounded,
                    onTap: _retake,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _actionButton(
                    label: 'Agendar con este corte',
                    icon: Icons.calendar_month_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1A1A1A),
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFD4A853),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Corte seleccionado: ${hairstyle?.name ?? ""}',
                                  style: GoogleFonts.lato(
                                    color: const Color(0xFFF5F0E8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFD4A853) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFFD4A853)
                : const Color(0xFF444444),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? const Color(0xFF0D0D0D) : Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? const Color(0xFF0D0D0D) : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HairstyleOverlayPainter extends CustomPainter {
  final HairstyleModel hairstyle;
  final double opacity;

  _HairstyleOverlayPainter({
    required this.hairstyle,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getHairstyleColor().withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    switch (hairstyle.category) {
      case 'Fade':
        _drawFade(canvas, paint, size);
        break;
      case 'Pompadour':
        _drawPompadour(canvas, paint, size);
        break;
      case 'Undercut':
        _drawUndercut(canvas, paint, size);
        break;
      default:
        _drawDefault(canvas, paint, size);
    }
  }

  Color _getHairstyleColor() {
    return const Color(0xFF3D2B1F);
  }

  void _drawFade(Canvas canvas, Paint paint, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.1, 0, size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.9, 0, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPompadour(Canvas canvas, Paint paint, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.1,
      -size.height * 0.2,
      size.width * 0.5,
      -size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      -size.height * 0.2,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawUndercut(Canvas canvas, Paint paint, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.2, 0, size.width * 0.5, 0);
    path.quadraticBezierTo(
      size.width * 0.8,
      0,
      size.width * 0.9,
      size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDefault(Canvas canvas, Paint paint, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.15, 0, size.width * 0.5, 0);
    path.quadraticBezierTo(
      size.width * 0.85,
      0,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HairstyleOverlayPainter oldDelegate) {
    return oldDelegate.hairstyle != hairstyle || oldDelegate.opacity != opacity;
  }
}

class _ResultOverlayPainter extends CustomPainter {
  final HairstyleModel hairstyle;
  final double opacity;

  _ResultOverlayPainter({
    required this.hairstyle,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A1A0A).withOpacity(opacity * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final centerX = size.width / 2;
    final topY = size.height * 0.05;
    final hairWidth = size.width * 0.55;

    final path = Path();
    path.moveTo(centerX - hairWidth / 2, size.height * 0.35);

    switch (hairstyle.category) {
      case 'Pompadour':
        path.quadraticBezierTo(
          centerX - hairWidth * 0.6,
          topY - size.height * 0.05,
          centerX,
          topY - size.height * 0.08,
        );
        path.quadraticBezierTo(
          centerX + hairWidth * 0.6,
          topY - size.height * 0.05,
          centerX + hairWidth / 2,
          size.height * 0.35,
        );
        break;
      default:
        path.quadraticBezierTo(
          centerX - hairWidth * 0.5,
          topY,
          centerX,
          topY,
        );
        path.quadraticBezierTo(
          centerX + hairWidth * 0.5,
          topY,
          centerX + hairWidth / 2,
          size.height * 0.35,
        );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ResultOverlayPainter oldDelegate) {
    return oldDelegate.hairstyle != hairstyle || oldDelegate.opacity != opacity;
  }
}
