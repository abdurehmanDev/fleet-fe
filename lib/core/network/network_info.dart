// ─── Network Info ─────────────────────────────────────────────────────────────
// Abstract contract + implementation for network connectivity check
// ─────────────────────────────────────────────────────────────────────────────

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // For a proper implementation, add connectivity_plus package.
    // This is a simple placeholder that always returns true.
    // TODO: Integrate connectivity_plus for real network checks.
    return true;
  }
}
