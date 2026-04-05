import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/proof_model.dart';
import '../services/proof_service.dart';
import '../services/hash_service.dart';
import '../widgets/widgets.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _hashController = TextEditingController();

  bool _isVerifying = false;
  ProofModel? _verificationResult;
  String? _error;
  File? _selectedFile;
  String? _calculatedHash;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hashController.dispose();
    super.dispose();
  }

  Future<void> _verifyByHash() async {
    final hash = _hashController.text.trim();
    if (hash.isEmpty) {
      setState(() => _error = 'Please enter a digital fingerprint');
      return;
    }

    if (!HashService.isValidHash(hash)) {
      setState(() => _error = 'Invalid format. Must be 64 characters.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
      _verificationResult = null;
    });

    final proofService = context.read<ProofService>();
    final result = await proofService.verifyByHash(hash);

    setState(() {
      _isVerifying = false;
      _verificationResult = result;
      if (result == null) _error = 'No protected work found with this fingerprint';
    });
  }

  Future<void> _verifyByFile() async {
    if (_selectedFile == null) {
      setState(() => _error = 'Please select a file first');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
      _verificationResult = null;
    });

    final bytes = await _selectedFile!.readAsBytes();
    final proofService = context.read<ProofService>();
    final result = await proofService.verifyFile(bytes);

    setState(() {
      _isVerifying = false;
      _verificationResult = result;
      if (result == null) _error = 'This file is not registered in our system';
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      setState(() {
        _selectedFile = file;
        _calculatedHash = HashService.generateHash(bytes);
        _error = null;
        _verificationResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  const GradientText(
                    text: 'Verify Ownership',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check if a work is protected',
                    style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Custom styled TabBar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(51),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withAlpha(128),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint, size: 18),
                              SizedBox(width: 6),
                              Text('Fingerprint'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, size: 18),
                              SizedBox(width: 6),
                              Text('Upload File'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHashVerification(),
                  _buildFileVerification(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashVerification() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input card
          GradientBorderCard(
            gradientColors: [Colors.white.withAlpha(38), Colors.white.withAlpha(13)],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconCircle(icon: Icons.fingerprint, color: AppTheme.primary, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enter Digital Fingerprint', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('Paste the SHA-256 hash to verify', style: TextStyle(color: Colors.white.withAlpha(102), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hashController,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g., a3f2b5c8d1e4f6a7b8c9d0e1f2a3...',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(51)),
                    prefixIcon: const Icon(Icons.tag, color: AppTheme.primary, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(25)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.black.withAlpha(51),
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: _isVerifying ? 'Verifying...' : 'Verify Fingerprint',
                  icon: Icons.search,
                  isLoading: _isVerifying,
                  onPressed: _verifyByHash,
                ),
              ],
            ),
          ),

          // QR Code option
          const SizedBox(height: 16),
          GradientOutlineButton(
            text: 'Scan QR Code',
            icon: Icons.qr_code_scanner,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('QR Scanner coming soon!'),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildFileVerification() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upload section
          GradientBorderCard(
            gradientColors: [Colors.white.withAlpha(38), Colors.white.withAlpha(13)],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconCircle(icon: Icons.upload_file, color: AppTheme.secondary, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Upload a File', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('We\'ll check if it\'s been registered', style: TextStyle(color: Colors.white.withAlpha(102), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                UploadZone(
                  height: 130,
                  onTap: _pickFile,
                  child: _selectedFile != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insert_drive_file, size: 32, color: AppTheme.primary),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _selectedFile!.path.split(Platform.pathSeparator).last,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ],
            ),
          ),

          if (_calculatedHash != null) ...[
            const SizedBox(height: 16),
            GradientBorderCard(
              gradientColors: [AppTheme.success.withAlpha(100), AppTheme.primary.withAlpha(51)],
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fingerprint, size: 16, color: AppTheme.success),
                      const SizedBox(width: 8),
                      Text('Digital Fingerprint', style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    HashService.formatHashForDisplay(_calculatedHash!),
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withAlpha(204)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          GradientButton(
            text: _isVerifying ? 'Verifying...' : 'Verify File',
            icon: Icons.verified,
            isLoading: _isVerifying,
            onPressed: _selectedFile == null ? null : _verifyByFile,
          ),
          const SizedBox(height: 24),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_error != null) {
      return GradientBorderCard(
        gradientColors: [AppTheme.error.withAlpha(100), AppTheme.error.withAlpha(38)],
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppTheme.error, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Not Found', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(_error!, style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_verificationResult != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientBorderCard(
            gradientColors: [AppTheme.success.withAlpha(100), AppTheme.success.withAlpha(38)],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: AppTheme.success, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Verified! ✅', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text('Protected by ${_verificationResult!.creatorName}',
                          style: TextStyle(color: Colors.white.withAlpha(179))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ProofCard(proof: _verificationResult!),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
