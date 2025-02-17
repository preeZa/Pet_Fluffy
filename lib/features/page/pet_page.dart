// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:Pet_Fluffy/features/page/navigator_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';

class Pet_Page extends StatefulWidget {
  const Pet_Page({Key? key}) : super(key: key);

  @override
  State<Pet_Page> createState() => _Pet_PageState();
}

class _Pet_PageState extends State<Pet_Page> {
  User? user = FirebaseAuth.instance.currentUser;

  static const String tempPetImageUrl =
      "https://e7.pngegg.com/pngimages/59/659/png-clipart-computer-icons-scalable-graphics-avatar-emoticon-animal-fox-jungle-safari-zoo-icon-animals-orange-thumbnail.png";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _desController = TextEditingController();

  Uint8List? _profileImage;
  Uint8List? _normalImage;
  final TextEditingController _imageFileController = TextEditingController();

  String? _selectedType;
  String? _selectedBreed;
  String? _selectedGender;

  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  final List<String> _genders = ['ตัวผู้', 'ตัวเมีย'];
  List<String> _types = [];
  List<String> _breedsOfType1 = [];
  List<String> _breedsOfType2 = [];

  bool _isLoading = false;

  void _fetchTypeData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('pet_type').get();
      List<String> types =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _types = types;
      });
    } catch (error) {
      print("Failed to fetch type data: $error");
    }
  }

  void _fetchBreadDataDog() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('pet_bread').get();
      List<String> breeds =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _breedsOfType1 = breeds;
      });
    } catch (error) {
      print("Failed to fetch breed data: $error");
    }
  }

  void _fetchBreadDataCat() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('pet_bread_1').get();
      List<String> breeds =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _breedsOfType2 = breeds;
      });
    } catch (error) {
      print("Failed to fetch breed data: $error");
    }
  }

  // เพื่อเข้าถึงตัวเลือกรูปภาพของอุปกรณ์
  Future<void> selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      Uint8List? compressedImage = await compressImage(img);
      if (compressedImage != null) {
        // สร้างรูปภาพระเบิดจาก Uint8List
        setState(() {
          _profileImage = compressedImage;
        });
      } else {
        // กรณีเกิดข้อผิดพลาดในการบีบอัดภาพ
        print('Failed to compress image');
      }
    } else {
      // กรณีไม่ได้เลือกรูปภาพ
      print('No image selected');
    }
  }

  void selectNormalImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      Uint8List? compressedImage = await compressImage(img);
      setState(() {
        _normalImage = compressedImage;
        _imageFileController.text =
            _normalImage != null ? 'เลือกรูปภาพแล้ว' : '';
      });
    }
  }

  void deleteNormalImage() {
    setState(() {
      _normalImage = null;
      _imageFileController.text = '';
    });
  }

  // เพื่อแปลงข้อมูลรูปภาพ (ในรูปแบบ Uint8List) เป็นการเข้ารหัสแบบ base64
  String uint8ListToBase64(Uint8List data) {
    return base64Encode(data);
  }

  // เพื่อแสดงหน้าต่างเลือกวันที่และอัปเดตวันที่ที่เลือกและฟิลด์ข้อความที่เกี่ยวข้อง
  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose(); // ล้างทรัพยากร
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      _fetchTypeData();
      _fetchBreadDataDog();
      _fetchBreadDataCat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("เพิ่มข้อมูลสัตว์เลี้ยง",
              style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(), // แสดงสัญลักษณ์การโหลดข้อมูล
              )
            : SingleChildScrollView(
                child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        _profileImage != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_profileImage!),
                              )
                            : const CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(tempPetImageUrl),
                              ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                        child: Column(
                      children: [
                        TextField(
                          style: const TextStyle(fontSize: 14),
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'ชื่อสัตว์เลี้ยง',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                items: _types.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedType = newValue;
                                    _selectedBreed = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'ประเภทสัตว์เลี้ยง',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            if (_selectedType != null)
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedBreed,
                                  items: _getBreedsByType(_selectedType!)
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBreed = newValue;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'พันธุ์สัตว์เลี้ยง',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                items: _genders.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'เพศ',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(fontSize: 14),
                                controller: _colorController,
                                decoration: InputDecoration(
                                  labelText: 'สี',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                controller: _dateController,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: 'วันเกิด',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                ),
                                onTap: () => selectDate(context),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(fontSize: 14),
                                controller: _weightController,
                                keyboardType: TextInputType
                                    .number, // กำหนดให้แสดงช่องใส่เฉพาะตัวเลข
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly // จำกัดให้ใส่เฉพาะตัวเลข
                                ],
                                decoration: InputDecoration(
                                  labelText: 'น้ำหนัก',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(fontSize: 14),
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  labelText: 'ราคา (ค่าผสมพันธุ์)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: selectNormalImage,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.image),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _imageFileController.text.isNotEmpty
                                            ? _imageFileController.text
                                            : 'เลือกรูปใบเพ็ดดีกรี',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      // เพิ่ม IconButton สำหรับลบรูปภาพ
                                      onPressed: deleteNormalImage,
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.left,
                          controller: _desController,
                          decoration: InputDecoration(
                            labelText: 'รายละเอียดเพิ่มเติม',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 40, 15, 10),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ButtonTheme(
                          minWidth: 300,
                          height: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              addPetToFirestore();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('เพิ่มสัตว์เลี้ยง',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              )));
  }

  void addPetToFirestore() async {
    setState(() {
      _isLoading = true;
    });

    String userId = user!.uid;
    String profileBase64 =
        _profileImage != null ? base64Encode(_profileImage!) : '';
    String name = _nameController.text;
    String color = _colorController.text;
    String birtdate = _dateController.text;
    String weight = _weightController.text;
    String price = _priceController.text;
    String petdegreeBase64 =
        _normalImage != null ? base64Encode(_normalImage!) : '';
    String description = _desController.text;
    String type = _selectedType ?? '';
    String breed = _selectedBreed ?? '';
    String gender = _selectedGender ?? '';

    CollectionReference pets =
        FirebaseFirestore.instance.collection('Pet_User');

    try {
      DocumentReference newPetRef = await pets.add({
        'user_id': userId,
        'img_profile': profileBase64,
        'name': name,
        'color': color,
        'birthdate': birtdate,
        'weight': weight,
        'price': price,
        'pet_degree': petdegreeBase64,
        'description': description,
        'type_pet': type,
        'breed_pet': breed,
        'gender': gender,
      });

      String docId = newPetRef.id;

      await newPetRef.update({'pet_id': docId});

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true); // ปิดไดอะล็อกหลังจาก 2 วินาที
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const Navigator_Page(initialIndex: 0)),
              (route) => false,
            );
          });
          return const AlertDialog(
            title: Text('Success'),
            content: Text('เพิ่มสัตว์เลี้ยงสำเร็จ'),
          );
        },
      );
    } catch (error) {
      print("Failed to add pet: $error");

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getBreedsByType(String type) {
    switch (type) {
      case 'สุนัข':
        return _breedsOfType1;
      case 'แมว':
        return _breedsOfType2;
      default:
        return [];
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      return await file.readAsBytes();
    } else {
      return null;
    }
  }

  Future<Uint8List?> compressImage(Uint8List image) async {
    try {
      List<int> compressedImage = await FlutterImageCompress.compressWithList(
        image,
        minHeight: 720, // ลดความสูงเป็น 720 pixel
        minWidth: 1280, // ลดความกว้างเป็น 1280 pixel
        quality: 85, // ลดคุณภาพรูปภาพเป็น 85%
      );
      return Uint8List.fromList(compressedImage);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
}
