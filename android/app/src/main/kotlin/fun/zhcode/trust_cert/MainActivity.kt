package `fun`.zhcode.trust_cert

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.cert.X509Certificate

class MainActivity : FlutterActivity() {
    private val _CHANNEL = "fun.zhcode.trustcert/x509"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            _CHANNEL
        ).setMethodCallHandler { call, result ->
            if ("getCertHash" == call.method) {
                val certStr = call.argument<String>("certContent") as String
                result.success(getCertHash(certStr))
            }
        }
    }

    private fun getCertHash(certStr: String): String? {
        val certTools = CertTools.get()
        val x509: X509Certificate? = certTools.readCertificate(
            certStr.trimIndent()
        )
        if (x509 != null) {
            return certTools.getHash(x509.subjectX500Principal)
        }
        return null
    }
}
