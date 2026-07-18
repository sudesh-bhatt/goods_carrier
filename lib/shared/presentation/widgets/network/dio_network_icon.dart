import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/profile_image_utils.dart';

/// Auth-aware vehicle/type icon from `/storage/...` (SVG or raster).
///
/// Applies [color] via [BlendMode.srcIn] so chips/list icons match selection
/// foreground (white when selected, muted when not).
class DioNetworkIcon extends ConsumerStatefulWidget {
  const DioNetworkIcon({
    super.key,
    required this.reference,
    required this.placeholder,
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  /// Relative `/storage/...` path or absolute URL from masters `icon_url`.
  final String reference;
  final Widget placeholder;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  ConsumerState<DioNetworkIcon> createState() => _DioNetworkIconState();
}

class _DioNetworkIconState extends ConsumerState<DioNetworkIcon> {
  static final Map<String, Uint8List> _cache = {};

  Uint8List? _bytes;
  bool _failed = false;
  String? _loadedKey;

  String? get _resolvedUrl =>
      ProfileImageUtils.resolveNetworkUrl(widget.reference);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant DioNetworkIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference) {
      _ensureLoaded();
    }
  }

  void _ensureLoaded() {
    final url = _resolvedUrl;
    if (url == null || url.isEmpty) {
      _safeSetState(() {
        _bytes = null;
        _failed = true;
        _loadedKey = null;
      });
      return;
    }
    if (_loadedKey == url && (_bytes != null || _failed)) return;
    _loadedKey = url;
    final cached = _cache[url];
    if (cached != null) {
      _safeSetState(() {
        _bytes = cached;
        _failed = false;
      });
      return;
    }
    _load(url);
  }

  Future<void> _load(String url) async {
    _safeSetState(() {
      _bytes = null;
      _failed = false;
    });

    try {
      final dio = ref.read(absoluteUrlDioProvider);
      final response = await dio.get<Uint8List>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
          headers: const {'Accept': 'image/*,image/svg+xml,*/*'},
        ),
      );
      final bytes = response.data;
      if (!mounted || _loadedKey != url) return;
      if (bytes == null || bytes.isEmpty) {
        _safeSetState(() => _failed = true);
        return;
      }
      _cache[url] = bytes;
      _safeSetState(() => _bytes = bytes);
    } catch (_) {
      if (!mounted || _loadedKey != url) return;
      _safeSetState(() => _failed = true);
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  bool get _isSvg {
    final ref = widget.reference.toLowerCase();
    if (ref.contains('.svg')) return true;
    final bytes = _bytes;
    if (bytes == null || bytes.isEmpty) return false;
    final head = String.fromCharCodes(
      bytes.take(64).where((b) => b != 0),
    ).trimLeft().toLowerCase();
    return head.startsWith('<svg') || head.startsWith('<?xml');
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _resolvedUrl == null) return widget.placeholder;
    final bytes = _bytes;
    if (bytes == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder,
      );
    }

    final filter = widget.color != null
        ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
        : null;

    if (_isSvg) {
      return SvgPicture.memory(
        bytes,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        colorFilter: filter,
        placeholderBuilder: (_) => widget.placeholder,
      );
    }

    final image = Image.memory(
      bytes,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => widget.placeholder,
    );
    if (filter == null) return image;
    return ColorFiltered(colorFilter: filter, child: image);
  }
}

/// Vehicle-type icon: API `icon_url` with tint, else [fallback].
class VehicleTypeNetworkIcon extends StatelessWidget {
  const VehicleTypeNetworkIcon({
    super.key,
    this.iconUrl,
    required this.color,
    required this.size,
    required this.fallback,
  });

  final String? iconUrl;
  final Color color;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final url = iconUrl?.trim();
    if (url == null || url.isEmpty) return fallback;

    return SizedBox(
      width: size,
      height: size,
      child: DioNetworkIcon(
        reference: url,
        width: size,
        height: size,
        color: color,
        placeholder: fallback,
      ),
    );
  }
}
