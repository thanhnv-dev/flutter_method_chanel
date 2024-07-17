import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter method chanel with Wallet Core',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const platform = MethodChannel('flutter.dev/native-module');

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();

  String? mnemonic;
  String? bitcoinAddress;
  String? bitcoinKey;

  Future<void> createWallet() async {
    try {
      final result = await platform.invokeMethod<String?>('createWallet');
      debugPrint(result);
      setState(() {
        mnemonic = result;
      });
    } on PlatformException catch (e) {
      showError('CreateWallet error $e');
    }
  }

  Future<void> importWallet() async {
    try {
      await platform.invokeMethod<bool?>(
        'importWallet',
        mnemonic,
      );
      showError('ImportWallet success');
    } on PlatformException catch (e) {
      showError('ImportWallet error $e');
    }
  }

  Future<void> getBitcoinAddressAndKey() async {
    try {
      final result = await platform.invokeMethod<Map<dynamic, dynamic>?>('getBitcoinAddressAndKey', {
        "env": "DEV",
        "mnemonic": mnemonic,
      });
      setState(() {
        bitcoinAddress = result?["bitcoinAddress"];
        bitcoinKey = result?["bitcoinKey"];
      });
      debugPrint("GetBitcoinAddressAndKey: $result");
    } on PlatformException catch (e) {
      showError('GetBitcoinAddressAndKey error $e');
    }
  }

  void showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  void clearData() {
    controller.clear();
    setState(() {
      mnemonic = null;
      bitcoinAddress = null;
      bitcoinKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Flutter method chanel with Wallet Core"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _customText("Mnemonic: ", mnemonic ?? ""),
              _customText("Bitcoin address: ", bitcoinAddress ?? ""),
              _customText("Bitcoin key: ", bitcoinKey ?? ""),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Enter mnemonic",
                ),
                onChanged: (value) => setState(() {
                  mnemonic = value;
                }),
              ),
              ElevatedButton(
                onPressed: importWallet,
                child: const Text(
                  "Import wallet",
                ),
              ),
              ElevatedButton(
                onPressed: createWallet,
                child: const Text(
                  "Create new wallet",
                ),
              ),
              ElevatedButton(
                onPressed: getBitcoinAddressAndKey,
                child: const Text(
                  "Get Bitcoin address and key",
                ),
              ),
              ElevatedButton(
                onPressed: clearData,
                child: const Text(
                  "Clear data",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _customText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(
        10,
      ),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
