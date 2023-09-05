import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:root/root.dart';
import 'package:trust_cert/tools.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = Tools();
    tools.initSnakeMsgContext(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TrustCert',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff272848),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xfff4f5f9),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            color: const Color(0xff2F70FF),
            child: const Text(
              '选择 PEM/CRT 证书文件',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              if (await Root.isRooted() == true) {
                final cert = await getCertContent();
                if (cert != null) {
                  final hashName = await tools.getCertHash(cert.$2);
                  if (hashName != null) {
                    final newFileName = '$hashName.0';
                    final result = await tools.setTrustCert(cert.$1.path, newFileName);
                    if (result) {
                      tools.snakeMsg('设置成功~');
                    } else {
                      tools.snakeMsg('设置失败，我也不知道为什么~');
                    }
                  }
                }
              } else {
                tools.snakeMsg('未获取到root权限~');
              }
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xfff4f5f9),
    );
  }

  Future<(File, String)?> getCertContent() async {
    final tools = Tools();
    (File, String)? cert;
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      try {
        final filePath = result.paths.single;
        if (filePath != null) {
          final certFile = File(filePath);
          final certContent = certFile.readAsStringSync().trim();
          if (certContent.startsWith('-----BEGIN CERTIFICATE-----') &&
              certContent.endsWith('-----END CERTIFICATE-----')) {
            cert = (certFile, certContent);
          } else {
            tools.snakeMsg('非证书文件~');
          }
        }
      } catch (e) {
        tools.snakeMsg('文件解析错误~');
      }
    }
    return cert;
  }
}
