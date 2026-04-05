import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/proof_model.dart';
import '../services/proof_service.dart';
import '../services/wallet_service.dart';
import '../services/hash_service.dart';
import '../widgets/widgets.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedFile;
  String? _fileHash;
  ProofCategory _selectedCategory = ProofCategory.art;
  ProofVisibility _selectedVisibility = ProofVisibility.public;
  bool _storeOnChain = true;
  int _currentStep = 0;

  final _steps = [
    {'number': '01', 'title': 'Upload', 'icon': Icons.cloud_upload_outlined},
    {'number': '02', 'title': 'Details', 'icon': Icons.edit_outlined},
    {'number': '03', 'title': 'Protect', 'icon': Icons.shield_outlined},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mp3', 'pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
      final bytes = await _selectedFile!.readAsBytes();
      setState(() => _fileHash = HashService.generateHash(bytes));
    }
  }

  Future<void> _createProof() async {
    if (_selectedFile == null || _titleController.text.isEmpty) return;

    final proofService = context.read<ProofService>();
    proofService.setWalletService(context.read<WalletService>());

    final proof = await proofService.createProof(
      file: _selectedFile!,
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      visibility: _selectedVisibility,
      storeOnChain: _storeOnChain,
    );

    if (proof != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your work is now protected!'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    } else if (proofService.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(proofService.error!), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proofService = context.watch<ProofService>();
    final walletService = context.watch<WalletService>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const GradientText(text: 'Protect Your Work', fontSize: 18),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background blobs
          BackgroundBlob(
            color: AppTheme.secondary,
            size: 250,
            offset: const Offset(-80, 100),
            opacity: 0.15,
          ),
          BackgroundBlob(
            color: AppTheme.primary,
            size: 200,
            offset: Offset(size.width - 50, size.height * 0.5),
            opacity: 0.1,
          ),
          
          // Content
          proofService.isLoading
              ? _buildLoadingState(proofService)
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Step Progress
                        _buildStepProgress(),
                        const SizedBox(height: 28),

                        // Current step content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _currentStep == 0
                              ? _buildStep1()
                              : _currentStep == 1
                                  ? _buildStep2()
                                  : _buildStep3(walletService),
                        ),

                        const SizedBox(height: 28),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Row(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isActive = index == _currentStep;
        final isComplete = index < _currentStep;
        final color = isActive
            ? AppTheme.primary
            : isComplete
                ? AppTheme.success
                : Colors.white.withAlpha(77);

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Step indicator
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppTheme.primaryGradient : null,
                        color: isActive ? null : (isComplete ? AppTheme.success.withAlpha(51) : AppTheme.cardBg),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? Colors.transparent : (isComplete ? AppTheme.success : Colors.white.withAlpha(25)),
                          width: 1.5,
                        ),
                      ),
                      child: isComplete
                          ? const Icon(Icons.check, color: AppTheme.success, size: 20)
                          : Icon(step['icon'] as IconData, color: isActive ? Colors.white : Colors.white54, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? AppTheme.primary : Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: isComplete
                          ? LinearGradient(colors: [AppTheme.success, AppTheme.success.withAlpha(128)])
                          : null,
                      color: isComplete ? null : Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Select Your File',
          highlightWord: 'File',
          subtitle: 'Choose the creative work you want to protect',
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),

        // Upload Zone with gradient border
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: _selectedFile != null ? AppTheme.primaryGradient : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              margin: EdgeInsets.all(_selectedFile != null ? 2 : 0),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(_selectedFile != null ? 18 : 20),
                border: _selectedFile == null
                    ? Border.all(color: Colors.white.withAlpha(38), width: 1.5)
                    : null,
              ),
              child: _selectedFile != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const IconCircle(icon: Icons.insert_drive_file, color: AppTheme.primary, size: 56),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _selectedFile!.path.split(Platform.pathSeparator).last,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Change File',
                              style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, size: 36, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text('Tap to select a file', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Images, videos, documents, audio',
                          style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        // File hash display
        if (_fileHash != null) ...[
          const SizedBox(height: 20),
          GradientBorderCard(
            gradientColors: [AppTheme.success.withAlpha(153), AppTheme.primary.withAlpha(77)],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconCircle(icon: Icons.fingerprint, color: AppTheme.success, size: 36),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Digital Fingerprint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Unique signature generated', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withAlpha(38),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: AppTheme.success),
                          SizedBox(width: 4),
                          Text('Ready', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _fileHash!,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white.withAlpha(179)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Add Details',
          highlightWord: 'Details',
          subtitle: 'Give your work a title and description',
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),

        GradientBorderCard(
          gradientColors: [Colors.white24, Colors.white10],
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Give your work a name',
                icon: Icons.title,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'Describe your work',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              _buildEnhancedDropdown('Category', _selectedCategory, ProofCategory.values,
                  (v) => setState(() => _selectedCategory = v!)),
              const SizedBox(height: 18),
              _buildEnhancedDropdown('Visibility', _selectedVisibility, ProofVisibility.values,
                  (v) => setState(() => _selectedVisibility = v!)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
        prefixIcon: Icon(icon, color: AppTheme.primary.withAlpha(179), size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(51),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildEnhancedDropdown<T extends Enum>(String label, T value, List<T> items, Function(T?) onChanged) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppTheme.surface,
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(51),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.name[0].toUpperCase() + item.name.substring(1),
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStep3(WalletService walletService) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Review & Protect',
          highlightWord: 'Protect',
          subtitle: 'Confirm details before securing your work',
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),

        // Summary card
        GradientBorderCard(
          gradientColors: [AppTheme.primary.withAlpha(128), AppTheme.secondary.withAlpha(77)],
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSummaryRow(Icons.insert_drive_file, 'File', _selectedFile?.path.split(Platform.pathSeparator).last ?? 'N/A'),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.title, 'Title', _titleController.text.isNotEmpty ? _titleController.text : 'N/A'),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.category_outlined, 'Category', _selectedCategory.name[0].toUpperCase() + _selectedCategory.name.substring(1)),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.visibility_outlined, 'Visibility', _selectedVisibility.name[0].toUpperCase() + _selectedVisibility.name.substring(1)),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Blockchain toggle
        GradientBorderCard(
          gradientColors: walletService.isConnected
              ? [AppTheme.success.withAlpha(102), AppTheme.primary.withAlpha(51)]
              : [Colors.white24, Colors.white10],
          padding: const EdgeInsets.all(4),
          child: SwitchListTile(
            title: const Text('Permanent Blockchain Protection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                walletService.isConnected
                    ? 'Your proof will be stored forever on the blockchain'
                    : 'Connect wallet to enable permanent protection',
                style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 12),
              ),
            ),
            secondary: IconCircle(
              icon: Icons.link,
              color: walletService.isConnected ? AppTheme.success : Colors.white54,
              size: 40,
            ),
            value: _storeOnChain && walletService.isConnected,
            activeColor: AppTheme.success,
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
            onChanged: walletService.isConnected
                ? (value) => setState(() => _storeOnChain = value)
                : null,
          ),
        ),

        if (!walletService.isConnected) ...[
          const SizedBox(height: 16),
          GradientOutlineButton(
            text: 'Connect Wallet',
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () => walletService.connectWallet(),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary.withAlpha(179)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: GradientOutlineButton(
              text: 'Back',
              onPressed: () => setState(() => _currentStep--),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 14),
        Expanded(
          flex: _currentStep == 0 ? 1 : 1,
          child: GradientButton(
            text: _currentStep == 2 ? 'Protect Now' : 'Continue',
            icon: _currentStep == 2 ? Icons.shield : Icons.arrow_forward,
            onPressed: () {
              if (_currentStep == 0 && _selectedFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please select a file first'),
                    backgroundColor: AppTheme.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }
              if (_currentStep == 1 && _titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a title'),
                    backgroundColor: AppTheme.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _createProof();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ProofService proofService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: proofService.uploadProgress > 0 ? proofService.uploadProgress : null,
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  backgroundColor: Colors.white.withAlpha(25),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GradientText(
                        text: '${(proofService.uploadProgress * 100).toInt()}%',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _getProgressText(proofService.uploadProgress),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'Please wait...',
            style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getProgressText(double progress) {
    if (progress < 0.1) return 'Preparing your file...';
    if (progress < 0.5) return 'Uploading securely...';
    if (progress < 0.6) return 'Upload complete!';
    if (progress < 0.8) return 'Securing on blockchain...';
    if (progress < 1) return 'Finalizing protection...';
    return 'Complete!';
  }
}
