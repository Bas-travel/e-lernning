import 'key_value_backend.dart';
import 'secure_backend.dart';

/// Mobile and desktop: the platform keystore.
KeyValueBackend createDefaultBackend() => const SecureBackend();
