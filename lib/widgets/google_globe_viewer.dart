import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleGlobeViewer extends StatefulWidget {
  const GoogleGlobeViewer({super.key});

  @override
  State<GoogleGlobeViewer> createState() => _GoogleGlobeViewerState();
}

class _GoogleGlobeViewerState extends State<GoogleGlobeViewer> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _error = false;

  static const String _globeUrl =
      'https://www.google.com/maps/@0,0,2z?hl=pt-BR';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _loading = true;
            });
          },
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _loading = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _loading = false;
              _error = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_globeUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Card(
        child: SizedBox(
          height: 280,
          child: Center(
            child: FilledButton.tonalIcon(
              onPressed: () {
                setState(() {
                  _error = false;
                  _loading = true;
                  _controller.loadRequest(Uri.parse(_globeUrl));
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar mapa'),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const ColoredBox(
                color: Color(0xFFE0F2F1),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
