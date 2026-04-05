import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import 'wallet_service.dart';

class BlockchainService {
  // Contract ABI for CreatorProof
  static const String _contractAbi = '''
[
  {
    "inputs": [{"internalType": "string", "name": "_fileHash", "type": "string"}],
    "name": "storeProof",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "_proofId", "type": "uint256"}],
    "name": "getProof",
    "outputs": [
      {"internalType": "string", "name": "fileHash", "type": "string"},
      {"internalType": "uint256", "name": "timestamp", "type": "uint256"},
      {"internalType": "address", "name": "creator", "type": "address"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "string", "name": "_fileHash", "type": "string"}],
    "name": "getProofByHash",
    "outputs": [
      {"internalType": "uint256", "name": "proofId", "type": "uint256"},
      {"internalType": "uint256", "name": "timestamp", "type": "uint256"},
      {"internalType": "address", "name": "creator", "type": "address"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_fileHash", "type": "string"},
      {"internalType": "address", "name": "_creator", "type": "address"}
    ],
    "name": "verifyProof",
    "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "totalProofs",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  }
]
''';

  /// Store proof on blockchain
  static Future<Map<String, dynamic>> storeProof({
    required WalletService walletService,
    required String fileHash,
    required DateTime timestamp,
  }) async {
    if (!walletService.isConnected) {
      throw Exception('Wallet not connected');
    }

    final contractAddress = walletService.contractAddress;
    if (contractAddress.isEmpty) {
      throw Exception('Contract address not configured');
    }

    try {
      // Encode function call
      final contract = DeployedContract(
        ContractAbi.fromJson(_contractAbi, 'CreatorProof'),
        EthereumAddress.fromHex(contractAddress),
      );
      
      final storeFunction = contract.function('storeProof');
      final data = storeFunction.encodeCall([fileHash]);

      // Send transaction via WalletConnect
      final txHash = await walletService.sendTransaction(
        to: contractAddress,
        data: '0x${bytesToHex(data)}',
      );

      if (txHash == null) {
        throw Exception('Transaction failed');
      }

      // Wait for transaction receipt to get block number
      final client = Web3Client(walletService.currentRpcUrl, http.Client());
      TransactionReceipt? receipt;
      
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        receipt = await client.getTransactionReceipt(txHash);
        if (receipt != null) break;
      }

      client.dispose();

      return {
        'transactionHash': txHash,
        'blockNumber': receipt?.blockNumber?.blockNum,
        'contractAddress': contractAddress,
      };

    } catch (e) {
      debugPrint('Store proof on chain error: $e');
      rethrow;
    }
  }

  /// Verify proof on blockchain
  static Future<Map<String, dynamic>?> verifyProofOnChain({
    required String rpcUrl,
    required String contractAddress,
    required String fileHash,
  }) async {
    if (contractAddress.isEmpty) {
      return null;
    }

    final client = Web3Client(rpcUrl, http.Client());

    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_contractAbi, 'CreatorProof'),
        EthereumAddress.fromHex(contractAddress),
      );

      final getProofByHash = contract.function('getProofByHash');
      
      final result = await client.call(
        contract: contract,
        function: getProofByHash,
        params: [fileHash],
      );

      if (result.isEmpty || result[0] == BigInt.zero) {
        return null;
      }

      return {
        'proofId': (result[0] as BigInt).toInt(),
        'timestamp': DateTime.fromMillisecondsSinceEpoch(
          (result[1] as BigInt).toInt() * 1000,
        ),
        'creator': (result[2] as EthereumAddress).hex,
      };

    } catch (e) {
      debugPrint('Verify proof on chain error: $e');
      return null;
    } finally {
      client.dispose();
    }
  }

  /// Get total proofs count from contract
  static Future<int> getTotalProofs({
    required String rpcUrl,
    required String contractAddress,
  }) async {
    if (contractAddress.isEmpty) return 0;

    final client = Web3Client(rpcUrl, http.Client());

    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_contractAbi, 'CreatorProof'),
        EthereumAddress.fromHex(contractAddress),
      );

      final totalProofs = contract.function('totalProofs');
      
      final result = await client.call(
        contract: contract,
        function: totalProofs,
        params: [],
      );

      return (result[0] as BigInt).toInt();

    } catch (e) {
      debugPrint('Get total proofs error: $e');
      return 0;
    } finally {
      client.dispose();
    }
  }

  /// Get explorer URL for transaction
  static String getExplorerUrl(String txHash, {bool isMainnet = false}) {
    if (isMainnet) {
      return 'https://polygonscan.com/tx/$txHash';
    }
    return 'https://amoy.polygonscan.com/tx/$txHash';
  }

  /// Convert bytes to hex string
  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
