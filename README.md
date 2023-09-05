# trust_cert

移动crt/pem证书到system分区，设置为系统信任证书，需要root权限
重启后失效

# 原理

## 获取HASH

```shell
openssl x509 -subject_hash_old -in root.crt
```

## 移动到sys

```shell
mkdir -m 700 /data/local/tmp/my-ca-copy
cp /system/etc/security/cacerts/* /data/local/tmp/my-ca-copy/
mount -t tmpfs tmpfs /system/etc/security/cacerts
mv /data/local/tmp/my-ca-copy/* /system/etc/security/cacerts/
cp [cert path] /system/etc/security/cacerts/
chown root:root /system/etc/security/cacerts/*
chmod 644 /system/etc/security/cacerts/*
chcon u:object_r:system_file:s0 /system/etc/security/cacerts/*
rm -r /data/local/tmp/my-ca-copy
```
