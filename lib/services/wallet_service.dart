import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

enum WalletConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

enum NetworkType {
  polygonMainnet,
  polygonAmoy, // Testnet
}

class WalletService extends ChangeNotifier {
  static const String _polygonMainnetRpc = 'https://polygon-rpc.com';
  static const String _polygonAmoyRpc = 'https://rpc-amoy.polygon.technology';
  
  static const int _polygonMainnetChainId = 137;
  static const int _polygonAmoyChainId = 80002;

  // Contract addresses (to be set after deployment)
  static const String _contractAddressMainnet = '';
  static const String _contractAddressAmoy = '';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Web3Client? _web3Client;
  Web3App? _wcClient;
  SessionData? _wcSession;
  
  String? _walletAddress;
  NetworkType _currentNetwork = NetworkType.polygonAmoy;
  WalletConnectionStatus _status = WalletConnectionStatus.disconnected;
  String? _error;
  double? _balance;

  String? get walletAddress => _walletAddress;
  NetworkType get currentNetwork => _currentNetwork;
  WalletConnectionStatus get status => _status;
  String? get error => _error;
  double? get balance => _balance;
  bool get isConnected => _status == WalletConnectionStatus.connected;

  String get currentRpcUrl => _currentNetwork == NetworkType.polygonMainnet 
      ? _polygonMainnetRpc 
      : _polygonAmoyRpc;

  int get currentChainId => _currentNetwork == NetworkType.polygonMainnet 
      ? _polygonMainnetChainId 
      : _polygonAmoyChainId;

  String get contractAddress => _currentNetwork == NetworkType.polygonMainnet 
      ? _contractAddressMainnet 
      : _contractAddressAmoy;

  String get networkName => _currentNetwork == NetworkType.polygonMainnet 
      ? 'Polygon Mainnet' 
      : 'Polygon Amoy (Testnet)';

  WalletService() {
    _initWeb3();
  }

  void _initWeb3() {
    _web3Client = Web3Client(currentRpcUrl, http.Client());
  }

  Future<void> initWalletConnect() async {
    try {
      _wcClient = await Web3App.createInstance(
        projectId: 'YOUR_WALLETCONNECT_PROJECT_ID', // Get from cloud.walletconnect.com
        metadata: const PairingMetadata(
          name: 'Creator Proof',
          description: 'Blockchain-verified proof of creation',
          url: 'https://creatorproof.app',
          icons: ['https://creatorproof.app/icon.png'],
        ),
      );
      
      // Listen for session events
      _wcClient!.onSessionDelete.subscribe((args) {
        _handleDisconnect();
      });

      // Check for existing session
      final sessions = _wcClient!.getActiveSessions();
      if (sessions.isNotEmpty) {
        _wcSession = sessions.values.first;
        _walletAddress = _getAddressFromSession(_wcSession!);
        _status = WalletConnectionStatus.connected;
        await _loadBalance();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('WalletConnect init error: $e');
    }
  }

  String? _getAddressFromSession(SessionData session) {
    final accounts = session.namespaces['eip155']?.accounts;
    if (accounts != null && accounts.isNotEmpty) {
      // Format: eip155:chainId:address
      return accounts.first.split(':').last;
    }
    return null;
  }

  Future<String?> connectWallet() async {
    try {
      _status = WalletConnectionStatus.connecting;
      _error = null;
      notifyListeners();

      if (_wcClient == null) {
        await initWalletConnect();
      }

      // Create session
      final ConnectResponse response = await _wcClient!.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: ['eip155:$currentChainId'],
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      // Get URI for QR code or deep link
      final uri = response.uri;
      if (uri != null) {
        // In a real app, show QR code or open wallet app
        debugPrint('WalletConnect URI: $uri');
      }

      // Wait for approval
      _wcSession = await response.session.future;
      _walletAddress = _getAddressFromSession(_wcSession!);
      
      if (_walletAddress != null) {
        _status = WalletConnectionStatus.connected;
        await _secureStorage.write(key: 'wallet_address', value: _walletAddress);
        await _loadBalance();
      }

      notifyListeners();
      return _walletAddress;

    } catch (e) {
      _status = WalletConnectionStatus.error;
      _error = e.toString();
      notifyListeners();
      debugPrint('Connect wallet error: $e');
      return null;
    }
  }

  Future<void> disconnectWallet() async {
    try {
      if (_wcSession != null && _wcClient != null) {
        await _wcClient!.disconnectSession(
          topic: _wcSession!.topic,
          reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
        );
      }
      _handleDisconnect();
    } catch (e) {
      debugPrint('Disconnect error: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _wcSession = null;
    _walletAddress = null;
    _balance = null;
    _status = WalletConnectionStatus.disconnected;
    _secureStorage.delete(key: 'wallet_address');
    notifyListeners();
  }

  Future<void> _loadBalance() async {
    if (_walletAddress == null || _web3Client == null) return;

    try {
      final address = EthereumAddress.fromHex(_walletAddress!);
      final balanceWei = await _web3Client!.getBalance(address);
      _balance = balanceWei.getValueInUnit(EtherUnit.ether);
      notifyListeners();
    } catch (e) {
      debugPrint('Load balance error: $e');
    }
  }

  Future<void> switchNetwork(NetworkType network) async {
    _currentNetwork = network;
    _web3Client = Web3Client(currentRpcUrl, http.Client());
    if (isConnected) {
      await _loadBalance();
    }
    notifyListeners();
  }

  Future<String?> sendTransaction({
    required String to,
    required String data,
    BigInt? value,
  }) async {
    if (_wcSession == null || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final transaction = {
        'from': _walletAddress,
        'to': to,
        'data': data,
        'value': value != null ? '0x${value.toRadixString(16)}' : '0x0',
      };

      final result = await _wcClient!.request(
        topic: _wcSession!.topic,
        chainId: 'eip155:$currentChainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [transaction],
        ),
      );

      return result as String?;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _web3Client?.dispose();
    super.dispose();
  }
}
