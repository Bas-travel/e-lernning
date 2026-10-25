import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.courseName});

  final String courseName;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _downloading = false;

  String get _certificateId =>
      'AB-${widget.courseName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '-')}';

  String get _verificationURL => 'https://ablearning.com/certificates/$_certificateId';

  Future<void> _download() async {
    setState(() => _downloading = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _downloading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate PDF download has been prepared.')),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(ClipboardData(
      text: 'I completed ${widget.courseName} on AB LEARNING. Verify it here: $_verificationURL',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate link copied — ready to share.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: Colors.green, size: 80),
                const SizedBox(height: 16),
                const Text('Certificate of Completion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('This certifies that the learner has completed', style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text(
                  widget.courseName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text('Issued by AB LEARNING', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Certificate ID: $_certificateId', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _downloading ? null : _download,
                    icon: _downloading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download_outlined),
                    label: Text(_downloading ? 'Preparing PDF...' : 'Download PDF'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share_outlined),
                    label: const Text('Share Certificate'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Course'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
