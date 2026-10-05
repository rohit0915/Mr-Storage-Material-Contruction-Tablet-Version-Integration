import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detect images even when older uploads used application/octet-stream.
bool isChatImage(Map<String, dynamic> file) {
  final type = (file['type'] ?? file['mimeType'] ?? '')
      .toString()
      .toLowerCase();
  if (type.startsWith('image/')) return true;
  final name = (file['name'] ?? '').toString();
  final path = Uri.tryParse((file['url'] ?? '').toString())?.path ?? '';
  final extension = RegExp(
    r'\.(png|jpe?g|gif|webp|bmp|avif)$',
    caseSensitive: false,
  );
  return extension.hasMatch(name) || extension.hasMatch(path);
}

class ChatAttachment extends StatelessWidget {
  const ChatAttachment({super.key, required this.file, required this.color});
  final Map<String, dynamic> file;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final name = (file['name'] ?? 'Attachment').toString();
    final uri = Uri.tryParse((file['url'] ?? '').toString().trim());
    final valid =
        uri != null &&
        ['http', 'https'].contains(uri.scheme) &&
        uri.host.isNotEmpty;
    if (isChatImage(file) && valid) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Semantics(
            label: 'Open image: $name',
            button: true,
            child: InkWell(
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.black,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * .85,
                    height: MediaQuery.sizeOf(context).height * .8,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close preview',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: InteractiveViewer(
                            minScale: .5,
                            maxScale: 5,
                            child: Center(
                              child: _NetworkImage(
                                url: uri.toString(),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _NetworkImage(
                  url: uri.toString(),
                  fit: BoxFit.contain,
                  thumbnail: true,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: () async {
        var opened = false;
        if (valid) {
          try {
            opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (_) {
            /* Display error below. */
          }
        }
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open this attachment.')),
          );
        }
      },
      icon: const Icon(Icons.attach_file, size: 18),
      label: Text(name, overflow: TextOverflow.ellipsis),
    );
  }
}

class _NetworkImage extends StatefulWidget {
  const _NetworkImage({
    required this.url,
    required this.fit,
    this.thumbnail = false,
  });
  final String url;
  final BoxFit fit;
  final bool thumbnail;
  @override
  State<_NetworkImage> createState() => _NetworkImageState();
}

class _NetworkImageState extends State<_NetworkImage> {
  int revision = 0;
  @override
  Widget build(BuildContext context) => Image.network(
    widget.url,
    key: ValueKey(revision),
    fit: widget.fit,
    width: widget.thumbnail ? 280 : null,
    height: widget.thumbnail ? 200 : null,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
    errorBuilder: (context, error, stackTrace) => SizedBox(
      height: 160,
      child: Center(
        child: TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () async {
            await NetworkImage(widget.url).evict();
            if (mounted) setState(() => revision++);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Image unavailable · Retry'),
        ),
      ),
    ),
  );
}
