import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:root/root.dart';

class Tools {
  Tools._internal();

  factory Tools() => _instance;

  static final Tools _instance = Tools._internal();

  static const platform = MethodChannel('fun.zhcode.trustcert/x509');

  BuildContext? _context;

  void initSnakeMsgContext(BuildContext context) {
    _context ??= context;
  }

  Future<bool> setTrustCert(String sourcePath, String fileName) async {
    final sysTempfs = checkSys();
    if (!sysTempfs) {
      final success = await setSystemTmpfs();
      if (!success) {
        snakeMsg('挂载tmpfs失败~');
        await Future.delayed(
          const Duration(
            seconds: 1,
            milliseconds: 200,
          ),
        );
        return false;
      }
    }
    await moveCertToSys(sourcePath, fileName);
    return true;
  }

  bool checkSys() {
    final processResult = Process.runSync('df', ['-t', 'tmpfs']);
    if (processResult.exitCode == 0) {
      return processResult.stdout
          .toString()
          .contains('/system/etc/security/cacerts');
    }
    return false;
  }

  Future<bool> setSystemTmpfs() async {
    await Root.exec(cmd: """mkdir -m 700 /data/local/tmp/fun_zhcode_trustcert
cp /system/etc/security/cacerts/* /data/local/tmp/fun_zhcode_trustcert/
mount -t tmpfs tmpfs /system/etc/security/cacerts
mv /data/local/tmp/fun_zhcode_trustcert/* /system/etc/security/cacerts/
chown root:root /system/etc/security/cacerts/*
chmod 644 /system/etc/security/cacerts/*
chcon u:object_r:system_file:s0 /system/etc/security/cacerts/*
rm -r /data/local/tmp/fun_zhcode_trustcert""");
    return checkSys();
  }

  Future<String?> getCertHash(String certStr) async {
    String? result;
    try {
      result = await platform.invokeMethod<String?>(
        'getCertHash',
        {'certContent': certStr},
      );
    } on PlatformException catch (_) {
      snakeMsg('获取证书HASH失败~');
    }
    return result;
  }

  void snakeMsg(String msg) {
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(msg),
        dismissDirection: DismissDirection.down,
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(
          seconds: 1,
          milliseconds: 600,
        ),
      ),
    );
  }

  Future<void> moveCertToSys(String sourcePath, String fileName) async {
    await Root.exec(
        cmd: 'cp $sourcePath /system/etc/security/cacerts/$fileName');
  }
}
