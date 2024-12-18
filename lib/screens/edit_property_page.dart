// lib/screens/edit_property_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../constants/colors.dart'; // 색상 상수 임포트
import '../widgets/custom_app_bar.dart';

class EditPropertyPage extends StatefulWidget {
  final Property property;

  const EditPropertyPage({super.key, required this.property});

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String price;
  late String ownerName;
  late String phoneNumber;
  late String area;
  late String status;
  String? address;
  List<String> images = [];
  String? contractorName;
  String? contractorPhone;
  String? notes;
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  bool isUploading = false;
  late String propertyType;
  late String transactionType;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    name = widget.property.name;
    price = widget.property.price;
    ownerName = widget.property.ownerName;
    phoneNumber = widget.property.phoneNumber;
    area = widget.property.area;
    status = widget.property.status;
    address = widget.property.address;
    images = List.from(widget.property.images);
    contractorName = widget.property.contractorName;
    contractorPhone = widget.property.contractorPhone;
    notes = widget.property.notes;
    propertyType = widget.property.propertyType ?? Property.propertyTypes[0];
    transactionType =
        widget.property.transactionType ?? Property.transactionTypes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '매물 수정',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _showDeleteConfirmationDialog(
              Provider.of<PropertyService>(context, listen: false),
            ),
          ),
        ],
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

                    _buildImageSection(),

                    const SizedBox(height: 24),

                    // 기본 정보 섹션
                    _buildSection(
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
                            initialValue: name,
                            onSaved: (value) => name = value!,
                            icon: Icons.home,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '가격',
                            initialValue: price,
                            onSaved: (value) => price = value!,
                            keyboardType: TextInputType.number,
                            icon: Icons.monetization_on,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '면적',
                            initialValue: area,
                            onSaved: (value) => area = value!,
                            keyboardType: TextInputType.number,
                            icon: Icons.square_foot,
                            required: false,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '주소',
                            initialValue: address,
                            onSaved: (value) => address = value,
                            icon: Icons.location_on,
                            required: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 연락처 정보 섹션
                    _buildSection(
                      title: '연락처 정보',
                      child: Column(
                        children: [
                          _buildTextField(
                            label: '집주인 이름',
                            initialValue: ownerName,
                            onSaved: (value) => ownerName = value!,
                            icon: Icons.person,
                            required: false,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '전화번호',
                            initialValue: phoneNumber,
                            onSaved: (value) => phoneNumber = value!,
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone,
                            required: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 계약자 정보 섹션
                    _buildSection(
                      title: '계약자 정보',
                      child: Column(
                        children: [
                          _buildTextField(
                            label: '계약자 이름',
                            initialValue: contractorName,
                            onSaved: (value) => contractorName = value,
                            icon: Icons.person_outline,
                            required: false,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: '계약자 전화번호',
                            initialValue: contractorPhone,
                            onSaved: (value) => contractorPhone = value,
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone_outlined,
                            required: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 상태 및 메모 섹션
                    _buildSection(
                      title: '상태 및 메모',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: status,
                            decoration: InputDecoration(
                              labelText: '매물 상태',
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
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: notes,
                            decoration: InputDecoration(
                              labelText: '특이사항',
                              prefixIcon: const Icon(Icons.note),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                            onSaved: (value) => notes = value,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 버튼 섹션
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isUploading ? null : _updateProperty,
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            label: Text(
                              isUploading ? '저장 중...' : '저장',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteConfirmationDialog(
                                Provider.of<PropertyService>(context,
                                    listen: false)),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            label: const Text(
                              '삭제',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required Function(String?) onSaved,
    TextInputType? keyboardType,
    IconData? icon,
    bool required = true,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: required ? '$label*' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
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

  // 이미지 섹션 빌더
  Widget _buildImageSection() {
    return _buildSection(
      title: '이미지',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              // 기존 이미지 표시
              ...images.map((imageUrl) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: AppColors.inputBackground,
                              child: const Icon(Icons.error,
                                  color: AppColors.error),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            images.remove(imageUrl);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // 선택된 새로운 이미지 표시
              ...selectedImages.map((imageFile) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        File(imageFile.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImages.remove(imageFile);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // 이미지 추가 버튼
              Container(
                margin: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: _showImageSourceSelection,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isUploading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.inputBackground,
            ),
          ],
        ],
      ),
    );
  }

  // 이미지 소스 선택 다이얼로그 표시
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
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

  // 갤러리에서 이미지 선택
  Future<void> _pickImagesFromGallery() async {
    List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setState(() {
        selectedImages.addAll(pickedImages);
      });
      await _uploadImages();
    }
  }

  // 카메라에서 이미지 촬영
  Future<void> _pickImageFromCamera() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
      await _uploadImages();
    }
  }

  // 이미지 업로드
  Future<void> _uploadImages() async {
    setState(() {
      isUploading = true;
    });

    List<String> downloadUrls = [];

    for (var imageFile in selectedImages) {
      String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(File(imageFile.path));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadURL);
      } catch (e) {
        print('이미지 업로드 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() {
      images.addAll(downloadUrls);
      selectedImages.clear();
      isUploading = false;
    });
  }

  // 삭제 확인 대화상자 표시
  void _showDeleteConfirmationDialog(PropertyService propertyService) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '매물 삭제',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child:
                const Text('취소', style: TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.of(dialogContext).pop();
                await propertyService.deleteProperty(widget.property.id);

                if (!mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('매물이 성공적으로 삭제되었습니다.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('삭제 중 오류가 발생했습니다: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProperty() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isUploading = true);

      try {
        final updatedProperty = Property(
          id: widget.property.id,
          userId: widget.property.userId,
          name: name,
          price: price,
          ownerName: ownerName,
          phoneNumber: phoneNumber,
          area: area,
          status: status,
          address: address,
          images: images,
          contractorName: contractorName,
          contractorPhone: contractorPhone,
          notes: notes,
          propertyType: propertyType,
          transactionType: transactionType,
        );

        await Provider.of<PropertyService>(context, listen: false)
            .updateProperty(updatedProperty);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('매물이 성공적으로 수정되었습니다')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류가 발생했습니다: $e')),
        );
      } finally {
        if (mounted) setState(() => isUploading = false);
      }
    }
  }
}
