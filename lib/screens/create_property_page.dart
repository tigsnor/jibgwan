// lib/screens/create_property_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jibgwan/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import 'admin_main_page.dart'; // 매물 리스트 페이지 임포트
import '../constants/colors.dart'; // 색상 상수 임포트

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  _CreatePropertyPageState createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends State<CreatePropertyPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String price = '';
  String ownerName = '';
  String phoneNumber = '';
  String area = '';
  String status = '대기';
  String propertyType = '아파트';
  String transactionType = '매매';
  final List<XFile> _selectedImages = []; // 선택한 이미지 리스트
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // 이미지 업로드 함수
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('이미지 업로드 오류: $e');
      rethrow; // 예외를 상위로 전달
    }
  }

  // 이미지 소스 선택 팝업 표시
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('사진 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 갤러리에서 여러 이미지 선택
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
        print('${images.length} images selected from gallery.');
      }
    } catch (e) {
      print("이미지 선택 오류: $e");
    }
  }

  // 카메라로 사진 촬영
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
        print('Image captured from camera.');
      }
    } catch (e) {
      print("사진 촬영 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '새 매물 등록',
        showBackButton: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 이미지 섹션
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '매물 사진',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showImageSourceSelection,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('사진 추가',
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedImages.isNotEmpty)
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.2)),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              File(_selectedImages[index].path),
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: -12,
                                            right: -12,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.5),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImages
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 기본 정보 섹션
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: _buildSection(
                        title: '기본 정보',
                        child: Column(
                          children: [
                            // 매물 종류 선택
                            DropdownButtonFormField<String>(
                              value: propertyType,
                              decoration: InputDecoration(
                                labelText: '매물 종류',
                                prefixIcon: const Icon(Icons.home_work),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: Property.propertyTypes.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  propertyType = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // 매물 구분 선택
                            DropdownButtonFormField<String>(
                              value: transactionType,
                              decoration: InputDecoration(
                                labelText: '매물 구분',
                                prefixIcon: const Icon(Icons.real_estate_agent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items:
                                  Property.transactionTypes.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  transactionType = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: '매물 이름',
                              onSaved: (value) => name = value!,
                              icon: Icons.home,
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: '가격',
                              onSaved: (value) => price = value!,
                              keyboardType: TextInputType.number,
                              icon: Icons.monetization_on,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: '면적',
                              onSaved: (value) => area = value!,
                              keyboardType: TextInputType.number,
                              icon: Icons.square_foot,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 연락처 정보 섹션
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '연락처 정보',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '집주인 이름',
                            onSaved: (value) => ownerName = value!,
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '전화번호',
                            onSaved: (value) => phoneNumber = value!,
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 상태 선택
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '매물 상태',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: status,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.flag),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: <String>['대기', '예약', '가계약', '계약완료']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                status = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isUploading ? null : _createProperty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isUploading ? '등록 중...' : '매물 등록',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String?) onSaved,
    TextInputType? keyboardType,
    IconData? icon,
    bool required = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: required ? '$label*' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label을(를) 입력해주세요';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // 생성 버튼의 onPressed 콜백 함수 분리
  void _createProperty() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isUploading = true;
      });

      try {
        print('Uploading images...');
        // 이미지 업로드 및 URL 리스트 생성
        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          for (var xfile in _selectedImages) {
            String url = await uploadImage(File(xfile.path));
            imageUrls.add(url);
            print('Uploaded image: $url');
          }
        }
        // 새로운 매물 생성
        final newProperty = Property(
            id: '', // Firestore에서 자동 생성됨
            userId: '', // PropertyService에서 현재 사용자 ID로 덮어씌워짐
            name: name,
            price: price,
            ownerName: ownerName,
            phoneNumber: phoneNumber,
            area: area,
            status: status,
            images: imageUrls,
            propertyType: propertyType,
            transactionType: transactionType);

        print('Adding property to Firestore...');
        // 매물 서비스에 추가
        await Provider.of<PropertyService>(context, listen: false)
            .addProperty(newProperty);
        print('Property added to Firestore.');

        // 업로드 상태 해제 및 페이지 이동
        if (mounted) {
          setState(() {
            isUploading = false;
          });
          // 단순히 이전 화면으로 돌아가기
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('매물이 성공적으로 등록되었습니다')),
          );
        }
      } catch (e) {
        // 에러 처리
        print('매물 생성 중 오류 발생: $e');
        if (mounted) {
          setState(() {
            isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('매물 생성 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }
}
