// ignore_for_file: file_names, camel_case_types, avoid_print, no_leading_underscores_for_local_identifiers

import 'package:Pet_Fluffy/features/page/navigator_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';

class Edit_Pet_Page extends StatefulWidget {
  final Map<String, dynamic> petUserData;

  const Edit_Pet_Page({super.key, required this.petUserData});

  @override
  State<Edit_Pet_Page> createState() => _Edit_Pet_PageState();
}

class _Edit_Pet_PageState extends State<Edit_Pet_Page> {
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
  final List<String> _types = [];
  final List<String> _breedsOfType1 = [];
  final List<String> _breedsOfType2 = [];

  void _fetchTypeData() async {
    await FirebaseFirestore.instance
        .collection('pet_type')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String type = doc.get('name');
        setState(() {
          _types.add(type);
        });
      }
    }).catchError((error) {
      print("Failed to fetch type data: $error");
    });
  }

  void _fetchBreadDataDog() {
    FirebaseFirestore.instance
        .collection('pet_bread')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String bread = doc.get('name');
        setState(() {
          _breedsOfType1.add(bread);
        });
      }
    }).catchError((error) {
      print("Failed to fetch gender data: $error");
    });
  }

  void _fetchBreadDataCat() {
    FirebaseFirestore.instance
        .collection('pet_bread_1')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String bread = doc.get('name');
        setState(() {
          _breedsOfType2.add(bread);
        });
      }
    }).catchError((error) {
      print("Failed to fetch gender data: $error");
    });
  }

  // เพื่อเข้าถึงตัวเลือกรูปภาพของอุปกรณ์
  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    setState(() {
      _profileImage = img;
    });
  }

  void selectNormalImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    setState(() {
      _normalImage = img;
      _imageFileController.text = _normalImage != null
          ? 'normal_image.jpg'
          : ''; // แสดงชื่อไฟล์เมื่อมีการเลือกรูปภาพ
    });
  }

  // เพื่อแปลงข้อมูลรูปภาพ (ในรูปแบบ Uint8List) เป็นการเข้ารหัสแบบ base64
  String uint8ListToBase64(Uint8List data) {
    return base64Encode(data);
  }

  // เพื่อแสดงหน้าต่างเลือกวันที่และอัปเดตวันที่ที่เลือกและฟิลด์ข้อความที่เกี่ยวข้อง
  void selectDate() async {
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
    _imageFileController.dispose(); // ล้าง Controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchTypeData();
    _fetchBreadDataDog();
    _fetchBreadDataCat();

    _nameController.text = widget.petUserData['name'] ?? '';
    _colorController.text = widget.petUserData['color'] ?? '';
    _weightController.text = widget.petUserData['weight'] ?? '';
    _priceController.text = widget.petUserData['price'] ?? '';
    _desController.text = widget.petUserData['description'] ?? '';
    _dateController.text = widget.petUserData['birthdate'] ?? '';

    _selectedType = widget.petUserData['type_pet'] ?? '';
    _selectedBreed = widget.petUserData['breed_pet'] ?? '';
    _selectedGender = widget.petUserData['gender'] ?? '';

    // โหลดภาพโปรไฟล์ของสัตว์เลี้ยง (หากมี)
    String profileImageUrl = widget.petUserData['img_profile'] ?? '';
    if (profileImageUrl.isNotEmpty) {
      _profileImage = base64Decode(profileImageUrl);
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
        body: SingleChildScrollView(
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
                    // ignore: sort_child_properties_last
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                    bottom: -10,
                    left: 80,
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
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                                borderRadius: BorderRadius.circular(30.0)),
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
                                borderRadius: BorderRadius.circular(30.0)),
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
                          onTap:
                              selectDate, // เรียกใช้ฟังก์ชัน selectDate เมื่อกดที่ TextField
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
                                // ใช้ Flexible ครอบ Text สำหรับปรับความยาวของข้อความ
                                child: Text(
                                  _imageFileController.text.isNotEmpty
                                      ? _imageFileController.text
                                      : 'เลือกรูปภาพ',
                                  overflow: TextOverflow
                                      .ellipsis, // กำหนดการแสดงผลเมื่อข้อความเกินขอบเขต
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
                      contentPadding: const EdgeInsets.fromLTRB(10, 40, 15, 10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ButtonTheme(
                    minWidth: 300,
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        updatePetInFirestore(widget.petUserData['pet_id']);
                      },
                      // ignore: sort_child_properties_last
                      child: const Text('บันทึก', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ),
        )));
  }

  void updatePetInFirestore(String petId) {
    // ตรวจสอบว่าผู้ใช้เข้าสู่ระบบอยู่หรือไม่
    if (user != null) {
      String profileBase64 =
          _profileImage != null ? uint8ListToBase64(_profileImage!) : '';
      String name = _nameController.text;
      String color = _colorController.text;
      String birthdate = _dateController.text;
      String weight = _weightController.text;
      String price = _priceController.text;
      String petDegreeBase64 =
          _normalImage != null ? uint8ListToBase64(_normalImage!) : '';
      String description = _desController.text;
      String type = _selectedType ?? '';
      String breed = _selectedBreed ?? '';
      String gender = _selectedGender ?? '';

      CollectionReference pets =
          FirebaseFirestore.instance.collection('Pet_User');

      // ส่งข้อมูลไปยัง Firestore เพื่ออัปเดตเอกสารที่มี petId ตรงกับที่ระบุ
      pets.doc(petId).update({
        'img_profile': profileBase64,
        'name': name,
        'color': color,
        'birthdate': birthdate,
        'weight': weight,
        'price': price,
        'pet_degree': petDegreeBase64,
        'description': description,
        'type_pet': type,
        'breed_pet': breed,
        'gender': gender,
      }).then((value) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop(true); // ปิดไดอะล็อกหลังจาก 2 วินาที
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const Navigator_Page(initialIndex: 0)),
                (route) => false,
              );
            });
            return const AlertDialog(
              title: Text('Success'),
              content: Text('อัปเดตข้อมูลสัตว์เลี้ยงสำเร็จ'),
            );
          },
        );
      }).catchError((error) {
        print("Failed to update pet: $error");
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
}
