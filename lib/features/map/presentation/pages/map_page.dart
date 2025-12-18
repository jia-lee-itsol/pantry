import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/permission_service.dart';
import '../../../stock/domain/entities/stock_item.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/emergency_item_card.dart';

class EmergencyItem {
  final String name;
  final String recommendedQuantity;
  final bool isEssential;

  const EmergencyItem({
    required this.name,
    required this.recommendedQuantity,
    this.isEssential = false,
  });
}

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  Set<Marker> _markers = {};

  // 필수 비상 상품 목록
  static const List<EmergencyItem> emergencyItems = [
    EmergencyItem(name: '水', recommendedQuantity: '1人あたり1日3L × 7日', isEssential: true),
    EmergencyItem(name: '米', recommendedQuantity: '1人あたり3kg', isEssential: true),
    EmergencyItem(name: 'ラーメン', recommendedQuantity: '1人あたり7個', isEssential: true),
    EmergencyItem(name: '缶詰', recommendedQuantity: '1人あたり10個', isEssential: true),
    EmergencyItem(name: '乾パン', recommendedQuantity: '1人あたり5個', isEssential: true),
    EmergencyItem(name: '缶飲料', recommendedQuantity: '1人あたり10個'),
    EmergencyItem(name: 'お菓子', recommendedQuantity: '1人あたり5個'),
    EmergencyItem(name: '牛乳', recommendedQuantity: '1人あたり5パック'),
    EmergencyItem(name: '卵', recommendedQuantity: '1人あたり10個'),
    EmergencyItem(name: 'ハム', recommendedQuantity: '1人あたり5個'),
    EmergencyItem(name: 'チーズ', recommendedQuantity: '1人あたり3個'),
    EmergencyItem(name: 'パン', recommendedQuantity: '1人あたり5個'),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 권한 확인 및 요청
      bool hasPermission = await PermissionService.checkLocationPermission();
      if (!hasPermission) {
        hasPermission = await PermissionService.requestLocationPermission();
        if (!hasPermission) {
          if (await PermissionService.isLocationPermanentlyDenied() && mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('位置情報の許可が必要'),
                content: const Text(
                  '近くの避難所を探すために位置情報の許可が必要です。\n設定で位置情報の許可を有効にしてください。',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PermissionService.openSettings();
                    },
                    child: const Text('設定を開く'),
                  ),
                ],
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      
      // 피난소 로드
      await _loadShelters(position);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadShelters(Position currentPosition) async {
    // 현재 위치 마커
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
        infoWindow: const InfoWindow(title: '現在地'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    try {
      // 실제 피난소 데이터 로드
      final shelters = await ref.read(mapRepositoryProvider).getNearbyShelters(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // 피난소 마커들 추가
      for (int i = 0; i < shelters.length; i++) {
        final shelter = shelters[i];
        markers.add(
          Marker(
            markerId: MarkerId('shelter_${shelter.id}'),
            position: LatLng(shelter.latitude, shelter.longitude),
            infoWindow: InfoWindow(
              title: shelter.name,
              snippet: shelter.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('避難所の読み込みに失敗しました: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  int? _getCurrentQuantity(String itemName, List<StockItem> stockItems) {
    try {
      final item = stockItems.firstWhere(
        (item) => item.name == itemName,
      );
      return item.quantity;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return AppScaffold(
      title: const Text('地震避難所及び非常用品'),
      body: Column(
        children: [
          // Google Maps
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: _isLoadingLocation
                ? const Center(child: CircularProgressIndicator())
                : _currentPosition == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              '位置情報を取得できません。',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              child: const Text('再試行'),
                            ),
                          ],
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 14,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                      ),
          ),

          // 비상용품 리스트
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: '必須非常用品'),
                      Tab(text: '推奨非常用品'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 필수 비상용품
                        stockItemsAsync.when(
                          data: (stockItems) {
                            final essentialItems = emergencyItems
                                .where((item) => item.isEssential)
                                .toList();

                            if (essentialItems.isEmpty) {
                              return const Center(
                                child: Text('必須非常用品リストがありません。'),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: essentialItems.length,
                              itemBuilder: (context, index) {
                                final item = essentialItems[index];
                                final quantity =
                                    _getCurrentQuantity(item.name, stockItems);
                                return EmergencyItemCard(
                                  itemName: item.name,
                                  recommendedQuantity: item.recommendedQuantity,
                                  currentQuantity: quantity,
                                  isEssential: true,
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Center(
                            child: Text('エラー: $error'),
                          ),
                        ),
                        // 추천 비상용품
                        stockItemsAsync.when(
                          data: (stockItems) {
                            final recommendedItems = emergencyItems
                                .where((item) => !item.isEssential)
                                .toList();

                            if (recommendedItems.isEmpty) {
                              return const Center(
                                child: Text('推奨非常用品リストがありません。'),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: recommendedItems.length,
                              itemBuilder: (context, index) {
                                final item = recommendedItems[index];
                                final quantity =
                                    _getCurrentQuantity(item.name, stockItems);
                                return EmergencyItemCard(
                                  itemName: item.name,
                                  recommendedQuantity: item.recommendedQuantity,
                                  currentQuantity: quantity,
                                  isEssential: false,
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Center(
                            child: Text('エラー: $error'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
