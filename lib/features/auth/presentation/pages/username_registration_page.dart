import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../household/presentation/providers/household_provider.dart';

// ============================================
// Username Registration Page
// ============================================

/// Page for registering a unique username.
///
/// This page allows users to register a unique username that other users
/// can use to find and add them. The username can only be set once and
/// cannot be changed later.
///
/// Features:
/// - Real-time username availability checking
/// - Input validation (3-20 alphanumeric characters)
/// - Debounced API calls to check availability
/// - Visual feedback for availability status
/// - User guidance on username requirements
///
/// Responsibilities:
/// - Validate username format
/// - Check username availability in real-time
/// - Register username via household provider
/// - Handle success and error states
/// - Navigate back after successful registration
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: '/username-registration',
///   builder: (context, state) => const UsernameRegistrationPage(),
/// ),
/// ```
class UsernameRegistrationPage extends ConsumerStatefulWidget {
  const UsernameRegistrationPage({super.key});

  @override
  ConsumerState<UsernameRegistrationPage> createState() =>
      _UsernameRegistrationPageState();
}

class _UsernameRegistrationPageState
    extends ConsumerState<UsernameRegistrationPage> {
  /// Text controller for the username input field
  final _controller = TextEditingController();

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Whether an availability check is in progress
  bool _isChecking = false;

  /// Whether the current username is available (null = not checked)
  bool? _isAvailable;

  /// Error message from availability check
  String? _checkError;

  /// Timer for debouncing username input
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handles username input changes.
  ///
  /// This method resets the availability state and schedules a debounced
  /// availability check. The check is only performed if the input is not
  /// empty and matches the required format.
  ///
  /// Parameters:
  /// - [value]: The current username input value
  void _onUsernameChanged(String value) {
    setState(() {
      _isAvailable = null;
      _checkError = null;
    });

    _debounceTimer?.cancel();

    if (value.isEmpty) return;

    // Validate format before checking availability
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]{3,20}$');
    if (!usernameRegex.hasMatch(value)) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkAvailability(value);
    });
  }

  /// Checks if the given username is available.
  ///
  /// This method queries the username repository to check availability.
  /// It updates the UI state based on the result or any errors that occur.
  ///
  /// Parameters:
  /// - [username]: The username to check for availability
  Future<void> _checkAvailability(String username) async {
    setState(() {
      _isChecking = true;
      _checkError = null;
    });

    try {
      final repository = ref.read(usernameRepositoryProvider);
      final available = await repository.isUsernameAvailable(username);

      if (mounted && _controller.text.toLowerCase() == username.toLowerCase()) {
        setState(() {
          _isAvailable = available;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkError = '확인 중 오류가 발생했습니다';
          _isChecking = false;
        });
      }
    }
  }

  /// Validates the username input.
  ///
  /// This method checks if the username meets all requirements:
  /// - Not empty
  /// - Between 3-20 characters
  /// - Contains only alphanumeric characters (a-z, A-Z, 0-9)
  ///
  /// Parameters:
  /// - [value]: The username value to validate
  ///
  /// Returns an error message if validation fails, null if valid.
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '아이디를 입력해주세요';
    }
    if (value.length < 3) {
      return '3자 이상 입력해주세요';
    }
    if (value.length > 20) {
      return '20자 이하로 입력해주세요';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!usernameRegex.hasMatch(value)) {
      return '영문과 숫자만 사용 가능합니다';
    }
    return null;
  }

  /// Registers the username.
  ///
  /// This method validates the form and checks if the username is available
  /// before attempting registration. On success, displays a success message
  /// and navigates back. On failure, displays an error message.
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isAvailable != true) return;

    final username = _controller.text.trim();
    final success = await ref
        .read(householdActionsProvider.notifier)
        .registerUsername(username);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('아이디가 등록되었습니다: @$username'),
          backgroundColor: Colors.green,
        ),
      );
      // Invalidate username provider to refresh the cached value
      ref.invalidate(currentUsernameProvider);
      context.pop();
    } else if (mounted) {
      final error = ref.read(householdActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '등록에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionsState = ref.watch(householdActionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Information card explaining username requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '아이디 안내',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 아이디는 다른 사용자가 회원님을 찾을 때 사용됩니다\n'
                      '• 영문과 숫자만 사용 가능합니다 (3-20자)\n'
                      '• 한 번 등록하면 변경할 수 없습니다',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Username input
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '아이디',
                  hintText: '영문, 숫자 3-20자',
                  prefixIcon: const Icon(Icons.alternate_email),
                  prefixText: '@',
                  suffixIcon: _buildSuffixIcon(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                onChanged: _onUsernameChanged,
                validator: _validateUsername,
              ),

              const SizedBox(height: 8),

              // Username availability status message
              if (_checkError != null)
                _buildStatusText(_checkError!, Colors.red)
              else if (_isChecking)
                _buildStatusText('확인 중...', Colors.grey)
              else if (_isAvailable == true)
                _buildStatusText('사용 가능한 아이디입니다', Colors.green)
              else if (_isAvailable == false)
                _buildStatusText('이미 사용 중인 아이디입니다', Colors.red),

              const SizedBox(height: 32),

              // Register button
              ElevatedButton(
                onPressed: actionsState.isLoading || _isAvailable != true
                    ? null
                    : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: actionsState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the suffix icon for the username input field.
  ///
  /// Returns:
  /// - Loading indicator while checking availability
  /// - Check mark icon if username is available
  /// - X mark icon if username is unavailable
  /// - null if no check has been performed
  Widget? _buildSuffixIcon() {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_isAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (_isAvailable == false) {
      return const Icon(Icons.cancel, color: Colors.red);
    }
    return null;
  }

  /// Builds a status text widget with the given text and color.
  ///
  /// Parameters:
  /// - [text]: The status message to display
  /// - [color]: The color for the text
  ///
  /// Returns a styled Text widget for displaying status messages.
  Widget _buildStatusText(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
