import 'dart:js_interop';

import 'key_value_backend.dart';

@JS('sessionStorage')
external _Storage get _session;

extension type _Storage._(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
  external void removeItem(JSString key);
}

/// Web: `sessionStorage`, which belongs to ONE browser tab. Every tab keeps
/// its own login, so several tabs can be signed in as different users or
/// roles at the same time. A refresh keeps the tab's session; closing the
/// tab ends it. (localStorage, which flutter_secure_storage uses on web, is
/// shared by all tabs, so a second login would overwrite the first.)
KeyValueBackend createDefaultBackend() => _SessionStorageBackend();

class _SessionStorageBackend implements KeyValueBackend {
  // Used only if the browser blocks sessionStorage (e.g. strict privacy mode).
  final _fallback = <String, String>{};

  @override
  Future<String?> read(String key) async {
    try {
      return _session.getItem(key.toJS)?.toDart;
    } on Object {
      return _fallback[key];
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      _session.setItem(key.toJS, value.toJS);
    } on Object {
      _fallback[key] = value;
    }
  }

  @override
  Future<void> delete(String key) async {
    _fallback.remove(key);
    try {
      _session.removeItem(key.toJS);
    } on Object {
      // Nothing stored, nothing to remove.
    }
  }
}
