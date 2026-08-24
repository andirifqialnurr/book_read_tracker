import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CoverPicker extends StatelessWidget {
  const CoverPicker({
    required this.coverUri,
    required this.onCoverChanged,
    super.key,
  });

  final String? coverUri;
  final ValueChanged<String?> onCoverChanged;

  Future<void> _pickCover() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    onCoverChanged(image.path);
  }

  @override
  Widget build(BuildContext context) {
    final path = coverUri;
    final hasCover = path != null && path.isNotEmpty && File(path).existsSync();
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _pickCover,
          child: Container(
            width: 128,
            height: 166,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .25),
                width: 1.5,
              ),
            ),
            child: hasCover
                ? Image.file(File(path), fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Add cover',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Optional',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
        if (hasCover) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => onCoverChanged(null),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Remove cover'),
          ),
        ],
      ],
    );
  }
}
