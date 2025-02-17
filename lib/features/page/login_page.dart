// ignore_for_file: use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:Pet_Fluffy/features/page/home.dart';
import 'package:Pet_Fluffy/features/page/reset_password.dart';
import 'package:Pet_Fluffy/features/page/sign_up_page.dart';
import 'package:Pet_Fluffy/features/splash_screen/setting_position.dart';
import 'package:Pet_Fluffy/pages/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  bool _isLoading = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  //ทำการลบตัวควบคุม หลังจากใช้งานเสร็จ เพื่อป้องกันการรั่วไหลของทรัพยากร
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Home_Page()),
                (route) => false);
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: size.width,
              height: size.height,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            hintText: "อีเมล์",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            hintText: "รหัสผ่าน",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                      ),
                      forgetPassword(context),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                          _signIn();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          backgroundColor:
                              Colors.blue, // ตั้งค่าสีพื้นหลังของปุ่มเป็นสีฟ้า
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30), // ปรับรูปร่างของปุ่มเป็นรูปวงกลม
                          ),
                        ),
                        child: Center(
                          child: _isSigning
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "เข้าสู่ระบบ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Divider(
                                color: Colors.grey,
                                thickness: 2,
                              ),
                            ),
                          ),
                          const Text(
                            "OR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Divider(
                                color: Colors.grey,
                                thickness: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          signInwithGoogle();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          backgroundColor:
                              const Color.fromARGB(255, 228, 216, 216),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: _isSigning
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LineAwesomeIcons.gofore,
                                      size: 32,
                                    ),
                                    SizedBox(
                                        width:
                                            10), // เพิ่มระยะห่างระหว่างไอคอนและข้อความ
                                    Text(
                                      "เข้าสู่ระบบด้วย Google",
                                      style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("คุณยังไม่มีบัญชี?",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                    (route) => false);
                              },
                              child: const Text(
                                "  สมัครสมาชิก",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                      const SizedBox(height: 30)
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white, // สีพื้นหลังสีดำทึบ
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('กำลังโหลดข้อมูล เพื่อเข้าสู่ระบบ....')
                  ],
                ), // แสดงหน้าโหลด
              ),
            )
        ],
      ),
    );
  }

  Future<String> convertImageToBase64(String imageUrl) async {
    // โหลดรูปภาพจาก URL
    http.Response response = await http.get(Uri.parse(imageUrl));

    // ตรวจสอบว่าโหลดรูปภาพสำเร็จหรือไม่
    if (response.statusCode == 200) {
      // แปลงข้อมูลรูปภาพเป็น Base64
      String base64Image = base64Encode(response.bodyBytes);
      return base64Image;
    } else {
      // หากโหลดรูปภาพไม่สำเร็จ คืนค่าว่าง
      return '';
    }
  }

  Future<void> saveUserGoogle(User user) async {
    // ตรวจสอบว่ามีข้อมูลของผู้ใช้ใน Firestore หรือไม่
    final userRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
    final userData = await userRef.get();
    String base64Image = await convertImageToBase64(user.photoURL!);

    if (!userData.exists) {
      // หากยังไม่มีข้อมูล จะทำการเพิ่มข้อมูลลงใน Firestore
      await userRef.set({
        'uid': user.uid,
        'username': user.displayName,
        'fullname': '',
        'email': user.email,
        'password': '',
        'photoURL': base64Image,
        'phone': user.phoneNumber,
        'nickname': '',
        'gender': '',
        'birtdate': '',
        'country': '',
        'facebeook': '',
        'line': ''
      }).then((_) {
        print("User data added to Firestore");
      }).catchError((error) {
        print("Failed to add user data: $error");
      });
    }
  }

  Future<void> signInwithGoogle() async {
    setState(() {
      _isSigning = true;
      _isLoading = true;
    });
    print("Hi Google Login");

    //gSn ส่งไปยังระบบการเข้าสู่ระบบของ Google
    final GoogleSignIn gSn = GoogleSignIn();
    //สร้างมาเก็บข้อมูลข้องผู้ใช้;
    User? user;

    try {
      //auth ส่งไปยังระบบการยืนยันสิทธิ์ของ Firebase
      FirebaseAuth auth = FirebaseAuth.instance;
      //รอให้ผู้ใช้เข้าสู่ระบบด้วยบัญชี Google แล้วเก็บข้อมูลในตัวแปร gAcc
      final GoogleSignInAccount? gAcc = await gSn.signIn();
      setState(() {
        _isSigning = true;
        _isLoading = true;
      });

      //เช็คการเข้าสู่ระบบ
      if (gAcc != null) {
        //รอรับข้อมูลการยืนยันสิทธิ์จาก Google
        final GoogleSignInAuthentication gAuth = await gAcc.authentication;

        //สร้างข้อมูลประจำตัวสำหรับเข้าสู่ระบบ Firebase
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        try {
          //รอผลการเข้าสู่ระบบ
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;
          print(user?.email);
          print(user?.displayName);

          await saveUserGoogle(user!);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const LocationSelectionPage()),
          );
        } on FirebaseAuthException catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
      _isLoading = true;
    });

    //ดึงค่าอีเมลและรหัสผ่านจากตัวควบคุม
    String email = _emailController.text;
    String password = _passwordController.text;

    // เช็ครูปแบบของอีเมล
    RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );

    if (!emailRegex.hasMatch(email)) {
      // หากรูปแบบของอีเมลไม่ถูกต้อง
      setState(() {
        _isSigning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รูปแบบของอีเมลไม่ถูกต้อง'),
        ),
      );
      return;
    }

    try {
      //เข้าสู่ระบบด้วยอีเมลและรหัสผ่านที่ดึงมาจากฟอร์ม
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      setState(() {
        _isSigning = false;
        _isLoading = false;
      });

      //ตรวจสอบการเข้าสู่ระบบ
      if (user != null) {
        // ตรวจสอบว่าอีเมลได้รับการยืนยันหรือไม่
        if (user.emailVerified) {
          print("User is Successfully sign-in");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const LocationSelectionPage()),
          );
        } else {
          // หากอีเมลยังไม่ได้รับการยืนยัน
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('โปรดยืนยันอีเมลก่อนเข้าสู่ระบบ'),
            ),
          );
        }
      } else {
        // หากไม่สามารถเข้าสู่ระบบได้ เช่นรหัสผ่านไม่ถูกต้อง
        setState(() {
          _isSigning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง'),
          ),
        );
      }
    } catch (error) {
      print("Error signing in: $error");
      setState(() {
        _isSigning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการเข้าสู่ระบบ'),
        ),
      );
    }
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "ลืมรหัสผ่าน?",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Get.to(() => const ResetPwd());
        },
      ),
    );
  }
}

class AppColor {
  static Color textColor = const Color(0xff9C9C9D);
  static Color textColorDark = const Color(0xffffffff);

  static Color bodyColor = const Color(0xffffffff);
  static Color bodyColorDark = const Color(0xff0E0E0F);

  static Color buttonBackgroundColor = const Color(0xffF7F7F7);
  static Color buttonBackgroundColorDark =
      const Color.fromARGB(255, 39, 36, 36);
}
