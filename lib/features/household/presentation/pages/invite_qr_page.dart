import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/entities/invite_code.dart';
import '../providers/household_provider.dart';

class InviteQRPage extends ConsumerStatefulWidget {
  const InviteQRPage({super.key});

  @override
  ConsumerState<InviteQRPage> createState() => _InviteQRPageState();
}

class _InviteQRPageState extends ConsumerState<InviteQRPage> {
  InviteCode? _inviteCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  Future<void> _generateCode() async {
    setState(() => _isLoading = true);
    final code = await ref.read(householdActionsProvider.notifier).generateInviteCode();
    setState(() {
      _inviteCode = code;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('멤버 초대'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inviteCode == null
              ? _buildErrorView()
              : _buildQRView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('초대 코드를 생성할 수 없습니다'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generateCode,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildQRView() {
    final code = _inviteCode!;
    final qrData = 'pantry://invite/${code.code}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '다른 사용자가 이 QR 코드를 스캔하면\n가구에 가입할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code.code,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('초대 코드가 복사되었습니다')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '유효 시간: ${_formatRemainingTime(code.remainingTime)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '초대받은 사용자는 조회자로 가입됩니다\n멤버 관리에서 역할을 변경할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _generateCode,
            icon: const Icon(Icons.refresh),
            label: const Text('새 코드 생성'),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }
}
