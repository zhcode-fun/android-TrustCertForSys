package `fun`.zhcode.trust_cert

import android.util.Log
import java.io.IOException
import java.io.InputStream
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import java.security.cert.CertificateException
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import javax.security.auth.x500.X500Principal


class CertTools {
    private val LOG_TAG = "CertTools"
    private var mCertFactory: CertificateFactory? = null

    constructor() {
        mCertFactory = CertificateFactory.getInstance("X.509");
    }

    companion object {
        private var instance: CertTools? = null
            get() {
                if (field == null) {
                    field = CertTools()
                }
                return field
            }

        @Synchronized
        fun get(): CertTools {
            return instance!!
        }
    }

    fun getHash(name: X500Principal): String? {
        val hash = hashName(name)
        return intToHexString(hash, 8)
    }

    private val DIGITS = charArrayOf(
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
    )

    private fun intToHexString(i: Int, minWidth: Int): String? {
        var i = i
        val bufLen = 8 // Max number of hex digits in an int
        val buf = CharArray(bufLen)
        var cursor = bufLen
        do {
            buf[--cursor] = DIGITS[i and 0xf]
        } while (4.let { i = i ushr it; i } != 0 || bufLen - cursor < minWidth)
        return String(buf, cursor, bufLen - cursor)
    }

    private fun hashName(principal: X500Principal): Int {
        return try {
            val digest = MessageDigest.getInstance("MD5").digest(principal.encoded)
            var offset = 0
            (digest[offset++].toInt() and 0xff shl 0 or (digest[offset++].toInt() and 0xff shl 8)
                    or (digest[offset++].toInt() and 0xff shl 16) or (digest[offset].toInt() and 0xff shl 24))
        } catch (e: NoSuchAlgorithmException) {
            throw AssertionError(e)
        }
    }

    fun readCertificate(file: String): X509Certificate? {
        var inputStream: InputStream? = null
        if (mCertFactory == null) {
            return null
        }
        return try {
            inputStream = file.byteInputStream(Charsets.UTF_8)
            mCertFactory!!.generateCertificate(inputStream) as X509Certificate
        } catch (e: CertificateException) {
            Log.e(LOG_TAG, "Failed to read certificate from $file", e)
            null
        } catch (e: IOException) {
            Log.e(LOG_TAG, "Failed to read certificate from $file", e)
            null
        } finally {
            inputStream?.close()
        }
    }
}