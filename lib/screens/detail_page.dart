// lib/screens/detail_page.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../models/property.dart';
import 'edit_property_page.dart';
import '../constants/colors.dart'; // 색상 상수 임포트

//git
class DetailPage extends StatefulWidget {
  final Property property;

  const DetailPage({super.key, required this.property});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.property.status;
  }

  @override
  Widget build(BuildContext context) {
    final propertyService =
        Provider.of<PropertyService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.property.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary, // 미디엄 블루 적용
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 매물 사진 슬라이드
            CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                scrollDirection: Axis.horizontal,
              ),
              items: widget.property.images.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.background,
                            child: const Icon(Icons.error,
                                size: 50, color: Colors.red),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // 현재 상태 수정 가능 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppColors.background, // 카드 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.accent),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '현재 상태',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            DropdownButton<String>(
                              value: status,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 16.0),
                              underline: Container(
                                height: 2,
                                color: AppColors.accent,
                              ),
                              onChanged: (newStatus) async {
                                if (newStatus == null) return;
                                setState(() {
                                  status = newStatus;
                                  // 새로운 Property 인스턴스 생성
                                  final updatedProperty = Property(
                                    id: widget.property.id,
                                    userId: widget.property.userId,
                                    name: widget.property.name,
                                    price: widget.property.price,
                                    ownerName: widget.property.ownerName,
                                    phoneNumber: widget.property.phoneNumber,
                                    area: widget.property.area,
                                    status: newStatus, // 새로운 상태 적용
                                    images: widget.property.images,
                                    address: widget.property.address,
                                    contractorName:
                                        widget.property.contractorName,
                                    contractorPhone:
                                        widget.property.contractorPhone,
                                    notes: widget.property.notes,
                                    propertyType: widget.property.propertyType,
                                    transactionType:
                                        widget.property.transactionType,
                                  );
                                  // PropertyService를 통해 업데이트
                                  propertyService
                                      .updateProperty(updatedProperty);
                                });
                                // 사용자에게 피드백 제공
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('상태가 "$newStatus"로 업데이트되었습니다.'),
                                    backgroundColor: AppColors.accent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              items: <String>[
                                '대기',
                                '예약',
                                '가계약',
                                '계약완료'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 계약자 정보 (조건부 표시)
            if (status == '예약' || status == '가계약')
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: AppColors.background, // 딥 그린 배경색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '계약자 정보',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ListTile(
                          leading:
                              const Icon(Icons.person, color: AppColors.accent),
                          title: const Text('계약자 이름'),
                          subtitle:
                              Text(widget.property.contractorName ?? '정보 없음'),
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.phone, color: AppColors.accent),
                          title: const Text('전화번호'),
                          subtitle:
                              Text(widget.property.contractorPhone ?? '정보 없음'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const Divider(),
            // 매물 상세 정보 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppColors.background, // 카드 배경색으로 변경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '매물 상세 정보',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      DetailItem(
                          title: '매물 이름', subtitle: widget.property.name),
                      DetailItem(title: '평형', subtitle: widget.property.area),
                      DetailItem(title: '가격', subtitle: widget.property.price),
                      DetailItem(
                          title: '집주인 이름', subtitle: widget.property.ownerName),
                      DetailItem(
                          title: '전화번호', subtitle: widget.property.phoneNumber),
                      DetailItem(
                        title: '매물 종류',
                        subtitle: widget.property.propertyType ?? '정보 없음',
                      ),
                      DetailItem(
                        title: '매물 구분',
                        subtitle: widget.property.transactionType ?? '정보 없음',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            // 특이사항 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: AppColors.background, // 카드 배경색으로 변경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '특이사항',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        widget.property.notes ?? '없음',
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent, // 딥 그린 배경색
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPropertyPage(property: widget.property),
            ),
          );
        },
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const DetailItem({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
