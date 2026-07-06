import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/billing/printer_provider.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().scanPrinters();
      final currentIp = context.read<PrinterProvider>().connectedIp;
      if (currentIp != null) {
        _ipController.text = currentIp;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'প্রিন্টার সেটিংস',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'ব্লুটুথ', icon: Icon(Icons.bluetooth)),
            Tab(text: 'ওয়াইফাই / নেটওয়ার্ক', icon: Icon(Icons.wifi)),
          ],
        ),
      ),
      body: Consumer<PrinterProvider>(
        builder: (context, printerProvider, child) {
          return Column(
            children: [
              _buildStatusCard(printerProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBluetoothTab(printerProvider),
                    _buildWifiTab(printerProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(PrinterProvider provider) {
    bool isConnected = provider.status == PrinterStatus.connected || 
                      (provider.connectedMac != null || provider.connectedIp != null);

    String connectionInfo = '';
    if (provider.connectionType == ConnectionType.bluetooth) {
      connectionInfo = 'ব্লুটুথ: ${provider.connectedName ?? provider.connectedMac}';
    } else if (provider.connectionType == ConnectionType.wifi) {
      connectionInfo = 'ওয়াইফাই: ${provider.connectedIp}';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.print : Icons.print_disabled,
                color: isConnected ? Colors.green : Colors.orange,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'প্রিন্টার সংযুক্ত আছে' : 'প্রিন্টার সংযুক্ত নেই',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isConnected ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                    if (isConnected)
                      Text(
                        connectionInfo,
                        style: GoogleFonts.hindSiliguri(color: Colors.green.shade700),
                      ),
                  ],
                ),
              ),
              if (isConnected)
                TextButton(
                  onPressed: () => provider.disconnectPrinter(),
                  child: Text(
                    'বিচ্ছিন্ন করুন',
                    style: GoogleFonts.hindSiliguri(color: Colors.red),
                  ),
                ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.testPrint('আমার হিসাব'),
                icon: const Icon(Icons.bug_report_outlined),
                label: Text('টেস্ট প্রিন্ট করুন', style: GoogleFonts.hindSiliguri()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBluetoothTab(PrinterProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'নিকটস্থ ব্লুটুথ ডিভাইস',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => provider.scanPrinters(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.status == PrinterStatus.scanning
              ? const Center(child: CircularProgressIndicator())
              : provider.devices.isEmpty
                  ? Center(child: Text('কোনো ডিভাইস পাওয়া যায়নি', style: GoogleFonts.hindSiliguri()))
                  : ListView.builder(
                      itemCount: provider.devices.length,
                      itemBuilder: (context, index) {
                        final device = provider.devices[index];
                        return ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(device.name),
                          subtitle: Text(device.macAdress),
                          trailing: ElevatedButton(
                            onPressed: () => provider.connectBluetoothPrinter(device.macAdress, device.name),
                            child: Text('সংযুক্ত করুন', style: GoogleFonts.hindSiliguri()),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildWifiTab(PrinterProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'নিকটস্থ ওয়াইফাই প্রিন্টার',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => provider.scanWifiPrinters(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.isWifiScanning)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
          else if (provider.wifiDevices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'কোনো প্রিন্টার পাওয়া যায়নি, স্ক্যান করুন অথবা আইপি লিখুন',
                  style: GoogleFonts.hindSiliguri(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.wifiDevices.length,
              itemBuilder: (context, index) {
                final ip = provider.wifiDevices[index];
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(ip),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _ipController.text = ip;
                      provider.connectWifiPrinter(ip);
                    },
                    child: Text('সংযুক্ত করুন', style: GoogleFonts.hindSiliguri()),
                  ),
                );
              },
            ),
          const Divider(height: 32),
          Text(
            'ম্যানুয়ালি প্রিন্টারের আইপি (IP Address) লিখুন',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              hintText: 'উদা: 192.168.1.100',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.network_ping),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.status == PrinterStatus.connecting
                  ? null
                  : () {
                      if (_ipController.text.isNotEmpty) {
                        provider.connectWifiPrinter(_ipController.text);
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: provider.status == PrinterStatus.connecting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('ওয়াইফাই প্রিন্টার সংযুক্ত করুন', style: GoogleFonts.hindSiliguri(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'নিশ্চিত করুন যে আপনার ফোন এবং প্রিন্টার একই ওয়াইফাই নেটওয়ার্কের সাথে সংযুক্ত আছে। সাধারণত পোর্ট ৯১০০ ব্যবহার করা হয়।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
