import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/household_provider.dart';

class JoinHouseholdPage extends ConsumerStatefulWidget {
  const JoinHouseholdPage({super.key});

  @override
  ConsumerState<JoinHouseholdPage> createState() => _JoinHouseholdPageState();
}

class _JoinHouseholdPageState extends ConsumerState<JoinHouseholdPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionsState = ref.watch(householdActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('가구 가입'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'QR 스캔'),
            Tab(icon: Icon(Icons.keyboard), text: '코드 입력'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQRScannerView(),
          _buildCodeInputView(actionsState),
        ],
      ),
    );
  }

  Widget _buildQRScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final value = barcode.rawValue;
              if (value != null && value.startsWith('pantry://invite/')) {
                final code = value.replaceFirst('pantry://invite/', '');
                _joinWithCode(code);
                break;
              }
            }
          },
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'QR 코드를 프레임 안에 맞춰주세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildCodeInputView(HouseholdActionsState actionsState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.vpn_key,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            '초대 코드 6자리를 입력하세요',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 32,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'ABC123',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              if (value.length == 6) {
                _joinWithCode(value);
              }
            },
          ),
          const SizedBox(height: 16),
          if (actionsState.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      actionsState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: actionsState.isLoading
                  ? null
                  : () => _joinWithCode(_codeController.text),
              child: actionsState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('가입하기'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinWithCode(String code) async {
    if (_isProcessing || code.length != 6) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    final success = await ref
        .read(householdActionsProvider.notifier)
        .joinHouseholdWithCode(code);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가구에 성공적으로 가입했습니다!')),
      );
      context.go('/');
    } else {
      setState(() => _isProcessing = false);
      _scannerController.start();
    }
  }
}
