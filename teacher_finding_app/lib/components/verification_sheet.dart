import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'buttons.dart';
import 'cards.dart';

class VerificationSheet extends StatefulWidget {
  final String token;
  final Function(User) onComplete;

  const VerificationSheet({
    super.key,
    required this.token,
    required this.onComplete,
  });

  @override
  State<VerificationSheet> createState() => _VerificationSheetState();
}

class _VerificationSheetState extends State<VerificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both CNIC Front and Back pictures for verification'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final frontBytes = await _cnicFrontImage!.readAsBytes();
      final frontBase64 = base64Encode(frontBytes);

      final backBytes = await _cnicBackImage!.readAsBytes();
      final backBase64 = base64Encode(backBytes);

      final updatedUser = await AuthService.completeVerification(
        token: widget.token,
        phone: _phoneController.text.trim(),
        cnicFront: frontBase64,
        cnicBack: backBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification details submitted successfully for admin approval.'),
            backgroundColor: AppTheme.success,
          ),
        );
        widget.onComplete(updatedUser);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      padding: EdgeInsets.fromLTRB(AppTheme.xl, AppTheme.xl, AppTheme.xl, AppTheme.xl + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Complete Profile Verification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppTheme.md),

              // Subtitle
              Text(
                'Please upload your CNIC Front/Back pictures and phone number to request or conduct class sessions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.lg),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'e.g. +923001234567',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.lg),

              // Image Pickers Card
              GlassCard(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CNIC Front
                    Text(
                      'CNIC Front Verification Picture',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppTheme.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _cnicFrontImage == null
                                ? 'No CNIC Front selected'
                                : 'Selected: ${_cnicFrontImage!.name}',
                            style: TextStyle(
                              color: _cnicFrontImage == null ? Colors.grey : AppTheme.success,
                              fontWeight: _cnicFrontImage == null ? FontWeight.normal : FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                            );
                            if (image != null) {
                              setState(() {
                                _cnicFrontImage = image;
                              });
                            }
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: Text(_cnicFrontImage == null ? 'Browse' : 'Change'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            foregroundColor: AppTheme.primary,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppTheme.xl),

                    // CNIC Back
                    Text(
                      'CNIC Back Verification Picture',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppTheme.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _cnicBackImage == null
                                ? 'No CNIC Back selected'
                                : 'Selected: ${_cnicBackImage!.name}',
                            style: TextStyle(
                              color: _cnicBackImage == null ? Colors.grey : AppTheme.success,
                              fontWeight: _cnicBackImage == null ? FontWeight.normal : FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                            );
                            if (image != null) {
                              setState(() {
                                _cnicBackImage = image;
                              });
                            }
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: Text(_cnicBackImage == null ? 'Browse' : 'Change'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            foregroundColor: AppTheme.primary,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.xl),

              // Submit Button
              PrimaryButton(
                label: 'Submit Verification Info',
                onPressed: _submit,
                isLoading: _isLoading,
                isEnabled: !_isLoading,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
