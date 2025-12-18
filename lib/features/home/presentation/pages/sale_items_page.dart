import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/permission_service.dart';

class SaleItem {
  final String id;
  final String storeName;
  final String productName;
  final String discount;
  final double latitude;
  final double longitude;
  final double distance; // 현재 위치로부터의 거리 (km)

  const SaleItem({
    required this.id,
    required this.storeName,
    required this.productName,
    required this.discount,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
}

class SaleItemsPage extends StatefulWidget {
  const SaleItemsPage({super.key});

  @override
  State<SaleItemsPage> createState() => _SaleItemsPageState();
}

class _SaleItemsPageState extends State<SaleItemsPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  final List<SaleItem> _saleItems = [];

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
          // 영구적으로 거부된 경우 설정 앱 열기 안내
          if (await PermissionService.isLocationPermanentlyDenied() && mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('位置情報の許可が必要'),
                content: const Text(
                  '近くのセール商品を探すために位置情報の許可が必要です。\n設定で位置情報の許可を有効にしてください。',
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
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('位置情報サービスが必要'),
              content: const Text('位置情報サービスを有効にしてください。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('確認'),
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _loadSaleItems(position);
      });

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

  void _loadSaleItems(Position currentPosition) {
    // 목업 데이터 - 실제로는 API에서 가져올 데이터
    final mockSaleItems = [
      {
        'id': '1',
        'storeName': 'スーパーマーケット',
        'productName': '新鮮野菜セット',
        'discount': '30% OFF',
        'latitude': currentPosition.latitude + 0.01,
        'longitude': currentPosition.longitude + 0.01,
      },
      {
        'id': '2',
        'storeName': 'フレッシュマート',
        'productName': '国産牛肉',
        'discount': '20% OFF',
        'latitude': currentPosition.latitude - 0.008,
        'longitude': currentPosition.longitude + 0.015,
      },
      {
        'id': '3',
        'storeName': 'デイリーマート',
        'productName': 'フルーツ特価',
        'discount': '15% OFF',
        'latitude': currentPosition.latitude + 0.015,
        'longitude': currentPosition.longitude - 0.01,
      },
      {
        'id': '4',
        'storeName': 'グリーンマート',
        'productName': '魚刺身セット',
        'discount': '25% OFF',
        'latitude': currentPosition.latitude - 0.012,
        'longitude': currentPosition.longitude - 0.008,
      },
      {
        'id': '5',
        'storeName': 'マート365',
        'productName': '有機牛乳',
        'discount': '10% OFF',
        'latitude': currentPosition.latitude + 0.02,
        'longitude': currentPosition.longitude + 0.02,
      },
    ];

    final items = mockSaleItems.map((item) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        item['latitude'] as double,
        item['longitude'] as double,
      ) / 1000; // km로 변환

      return SaleItem(
        id: item['id'] as String,
        storeName: item['storeName'] as String,
        productName: item['productName'] as String,
        discount: item['discount'] as String,
        latitude: item['latitude'] as double,
        longitude: item['longitude'] as double,
        distance: distance,
      );
    }).toList();

    // 거리순으로 정렬
    items.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      _saleItems.clear();
      _saleItems.addAll(items);
    });
  }

  Set<Marker> _getMarkers() {
    if (_currentPosition == null || _saleItems.isEmpty) {
      return {};
    }

    final markers = <Marker>{
      // 현재 위치 마커
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: const InfoWindow(title: '現在地'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    // 세일 매장 마커들
    for (final item in _saleItems) {
      markers.add(
        Marker(
          markerId: MarkerId(item.id),
          position: LatLng(item.latitude, item.longitude),
          infoWindow: InfoWindow(
            title: item.storeName,
            snippet: '${item.productName} ${item.discount}',
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('近くのセール情報'),
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
                        markers: _getMarkers(),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                      ),
          ),

          // 세일 아이템 리스트
          Expanded(
            child: _isLoadingLocation
                ? const Center(child: CircularProgressIndicator())
                : _saleItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              '近くのセール情報がありません。',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _saleItems.length,
                        itemBuilder: (context, index) {
                          final item = _saleItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(AppSpacing.md),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.store, size: 32),
                                ),
                                title: Text(
                                  item.storeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(item.productName),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.distance.toStringAsFixed(1)}km',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.discount,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  // 매장 선택 시 지도에서 해당 위치로 이동
                                  if (_mapController != null) {
                                    _mapController!.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                            item.latitude,
                                            item.longitude,
                                          ),
                                          zoom: 16,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
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

