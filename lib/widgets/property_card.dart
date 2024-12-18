// lib/widgets/property_card.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../screens/detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      ),
      memCacheWidth: 200, // 메모리 캐시 크기 제한
      maxWidthDiskCache: 400, // 디스크 캐시 크기 제한
    );
  }

  @override
  Widget build(BuildContext context) {
    // 상태별 색상 지정
    Color statusColor;
    switch (property.status) {
      case '대기':
        statusColor = Colors.orange;
        break;
      case '예약':
        statusColor = Colors.blue;
        break;
      case '가계약':
        statusColor = Colors.green;
        break;
      case '계약완료':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.black;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailPage(property: property),
              ),
            );
          },
          child: Hero(
            tag: 'property-${property.id}',
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 매물 이미지 (첫 번째 이미지 표시)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: property.images.isNotEmpty
                        ? _buildImage(property.images[0])
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.home),
                          ),
                  ),
                  const SizedBox(width: 16.0),
                  // 매물 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 매물 이름
                        Text(
                          property.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // 가격
                        Text(
                          '가격: ${property.price}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black87),
                        ),
                        const SizedBox(height: 4.0),
                        // 평형
                        Text(
                          '평형: ${property.area}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black87),
                        ),
                        const SizedBox(height: 4.0),
                        // 상태
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                property.status,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12.0),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            // 주소 표시 (선택적)
                            if (property.address != null &&
                                property.address!.isNotEmpty)
                              Expanded(
                                child: Text(
                                  property.address!,
                                  style: const TextStyle(
                                      fontSize: 12.0, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
