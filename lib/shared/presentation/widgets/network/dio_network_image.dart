import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';

/// Loads a protected image via [Dio] so auth interceptors attach the Bearer token.
///
/// Plain [Image.network] cannot access `/storage/...` driver document URLs.
class DioNetworkImage extends ConsumerStatefulWidget {
  const DioNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    required this.placeholder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget placeholder;

  @override
  ConsumerState<DioNetworkImage> createState() => _DioNetworkImageState();
}

class _DioNetworkImageState extends ConsumerState<DioNetworkImage> {
  Uint8List? _bytes;
  bool _failed = false;
  String? _loadedUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedUrl != widget.url) {
      _loadedUrl = widget.url;
      _load();
    }
  }

  Future<void> _load() async {
    safeSetState(() {
      _bytes = null;
      _failed = false;
    });

    try {
      final dio = ref.read(absoluteUrlDioProvider);
      final response = await dio.get<Uint8List>(
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
          headers: const {'Accept': 'image/*,*/*'},
        ),
      );
      final bytes = response.data;
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        safeSetState(() => _failed = true);
        return;
      }
      safeSetState(() => _bytes = bytes);
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _failed = true);
    }
  }

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => widget.placeholder,
      );
    }
    if (_failed) return widget.placeholder;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.placeholder,
    );
  }
}
