import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../models/printer_config.dart';
import '../../services/printer_settings_service.dart';
import '../../services/bluetooth_printer_service.dart';
import '../../widgets/printer_connection_dialog.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage>
    with SingleTickerProviderStateMixin {
  late PrinterSettingsService _settingsService;
  late BluetoothPrinterService _printerService;
  late TabController _tabController;
  List<PrinterConfig> _printers = [];

  @override
  void initState() {
    super.initState();
    _settingsService = PrinterSettingsService();
    _printerService = BluetoothPrinterService();
    _tabController = TabController(length: 3, vsync: this);
    _loadPrinters();

    // Maintain Bluetooth connection status in background
    _maintainBluetoothConnection();
  }

  void _maintainBluetoothConnection() {
    // Check connection every 5 seconds
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        await _printerService.maintainConnection();
        // Schedule next check
        Future.delayed(
          const Duration(seconds: 4),
          _maintainBluetoothConnection,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPrinters() {
    setState(() {
      _printers = _settingsService.getAllPrinters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('⚙️ Pengaturan Printer'),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
              Tab(icon: Icon(Icons.router), text: 'Jaringan'),
              Tab(icon: Icon(Icons.usb), text: 'USB'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildBluetoothTab(), _buildNetworkTab(), _buildUsbTab()],
        ),
      ),
    );
  }

  // ============================================================
  // BLUETOOTH TAB
  // ============================================================
  Widget _buildBluetoothTab() {
    final btPrinters = _printers
        .where((p) => p.type == PrinterType.bluetooth)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddBluetoothPrinter(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Printer Bluetooth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          if (btPrinters.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.bluetooth_disabled,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada printer Bluetooth',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: btPrinters.length,
              itemBuilder: (context, index) {
                return _buildPrinterCard(btPrinters[index]);
              },
            ),
        ],
      ),
    );
  }

  void _showAddBluetoothPrinter() {
    showDialog(
      context: context,
      builder: (context) => const PrinterConnectionDialog(),
    );
  }

  // ============================================================
  // NETWORK TAB
  // ============================================================
  Widget _buildNetworkTab() {
    final netPrinters = _printers
        .where((p) => p.type == PrinterType.network)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddNetworkDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Printer Jaringan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          if (netPrinters.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.router_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada printer Jaringan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: netPrinters.length,
              itemBuilder: (context, index) {
                return _buildPrinterCard(netPrinters[index]);
              },
            ),
        ],
      ),
    );
  }

  void _showAddNetworkDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddNetworkPrinterDialog(
        onSave: (config) {
          _settingsService.addPrinter(config);
          _loadPrinters();
          Navigator.pop(context);
        },
      ),
    );
  }

  // ============================================================
  // USB TAB
  // ============================================================
  Widget _buildUsbTab() {
    final usbPrinters = _printers
        .where((p) => p.type == PrinterType.usb)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddUsbDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Printer USB'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          if (usbPrinters.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.usb_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada printer USB',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: usbPrinters.length,
              itemBuilder: (context, index) {
                return _buildPrinterCard(usbPrinters[index]);
              },
            ),
        ],
      ),
    );
  }

  void _showAddUsbDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddUsbPrinterDialog(
        onSave: (config) {
          _settingsService.addPrinter(config);
          _loadPrinters();
          Navigator.pop(context);
        },
      ),
    );
  }

  // ============================================================
  // PRINTER CARD
  // ============================================================
  Widget _buildPrinterCard(PrinterConfig printer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              printer.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (printer.type == PrinterType.bluetooth)
                            StreamBuilder<bool>(
                              stream: _printerService.connectionStateStream,
                              builder: (context, snapshot) {
                                final isConnected =
                                    snapshot.data ??
                                    _printerService.isConnected;
                                final isThisPrinter =
                                    _printerService.connectedAddress ==
                                    printer.bluetoothAddress;
                                final statusColor =
                                    (isConnected && isThisPrinter)
                                    ? Colors.green
                                    : Colors.grey;
                                final statusText =
                                    (isConnected && isThisPrinter)
                                    ? '🟢 Connected'
                                    : '🔴 Disconnected';

                                return Chip(
                                  label: Text(statusText),
                                  backgroundColor: statusColor.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        printer.type.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getAddressDisplay(printer),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📄 ${printer.paperSize.displayName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (printer.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⭐ Default',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _testPrint(printer),
                  icon: const Icon(Icons.print),
                  label: const Text('Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _settingsService.setDefaultPrinter(printer.id).then((_) {
                        _loadPrinters();
                      }),
                  icon: const Icon(Icons.check),
                  label: const Text('Set Default'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirm(printer),
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getAddressDisplay(PrinterConfig printer) {
    switch (printer.type) {
      case PrinterType.bluetooth:
        return 'BT: ${printer.bluetoothAddress ?? 'N/A'}';
      case PrinterType.network:
        return 'IP: ${printer.networkIp ?? 'N/A'}:${printer.networkPort ?? 9100}';
      case PrinterType.usb:
        return 'USB Device';
    }
  }

  void _testPrint(PrinterConfig printer) async {
    if (kDebugMode) print('🖨️ Testing printer: ${printer.name}');

    try {
      bool success = false;

      switch (printer.type) {
        case PrinterType.bluetooth:
          // Connect to bluetooth printer first
          if (printer.bluetoothAddress != null) {
            final connected = await _printerService.connect(
              address: printer.bluetoothAddress!,
              deviceName: printer.name,
            );
            if (connected) {
              success = await _printerService.testPrint();
              // Don't disconnect for Bluetooth - keep it connected
              // This allows subsequent prints without reconnecting
              if (kDebugMode) print('🔌 Keeping Bluetooth connection alive');
            }
          }
          break;

        case PrinterType.network:
          // Connect to network printer
          if (printer.networkIp != null) {
            final connected = await _printerService.connectNetworkPrinter(
              ipAddress: printer.networkIp!,
              port: printer.networkPort ?? 9100,
            );
            if (connected) {
              success = await _printerService.testNetworkPrint(
                printer.paperSize,
              );
              await _printerService.disconnectNetworkPrinter();
            }
          }
          break;

        case PrinterType.usb:
          // Connect to USB printer
          final connected = await _printerService.connectUsbPrinter();
          if (connected) {
            success = await _printerService.testUsbPrint(printer.paperSize);
            await _printerService.disconnectUsbPrinter();
          }
          break;
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Test print ${printer.name} berhasil!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        await _settingsService.updateLastUsed(printer.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Test print ${printer.name} gagal'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Test error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConfirm(PrinterConfig printer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Printer?'),
        content: Text('Yakin ingin menghapus ${printer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _settingsService.deletePrinter(printer.id);
              _loadPrinters();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Printer dihapus'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADD NETWORK PRINTER DIALOG
// ============================================================
class _AddNetworkPrinterDialog extends StatefulWidget {
  final Function(PrinterConfig) onSave;

  const _AddNetworkPrinterDialog({required this.onSave});

  @override
  State<_AddNetworkPrinterDialog> createState() =>
      _AddNetworkPrinterDialogState();
}

class _AddNetworkPrinterDialogState extends State<_AddNetworkPrinterDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  late TextEditingController _portController;
  PaperSize _selectedPaperSize = PaperSize.mm58;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ipController = TextEditingController();
    _portController = TextEditingController(text: '9100');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Printer Jaringan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Printer',
                hintText: 'Contoh: Printer Kasir 1',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Alamat IP',
                hintText: '192.168.1.100',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '9100',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButton<PaperSize>(
              isExpanded: true,
              value: _selectedPaperSize,
              items: PaperSize.values.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('📄 ${size.displayName}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaperSize = value);
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Set sebagai default'),
              value: _isDefault,
              onChanged: (value) {
                setState(() => _isDefault = value ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _ipController.text.isEmpty ||
                _portController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Semua field harus diisi'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final config = PrinterConfig(
              id: const Uuid().v4(),
              name: _nameController.text,
              type: PrinterType.network,
              networkIp: _ipController.text,
              networkPort: int.tryParse(_portController.text) ?? 9100,
              paperSize: _selectedPaperSize,
              isDefault: _isDefault,
            );

            widget.onSave(config);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

// ============================================================
// ADD USB PRINTER DIALOG
// ============================================================
class _AddUsbPrinterDialog extends StatefulWidget {
  final Function(PrinterConfig) onSave;

  const _AddUsbPrinterDialog({required this.onSave});

  @override
  State<_AddUsbPrinterDialog> createState() => _AddUsbPrinterDialogState();
}

class _AddUsbPrinterDialogState extends State<_AddUsbPrinterDialog> {
  late TextEditingController _nameController;
  PaperSize _selectedPaperSize = PaperSize.mm58;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Printer USB'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Printer',
                hintText: 'Contoh: Printer Kasir USB',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<PaperSize>(
              isExpanded: true,
              value: _selectedPaperSize,
              items: PaperSize.values.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('📄 ${size.displayName}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaperSize = value);
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Set sebagai default'),
              value: _isDefault,
              onChanged: (value) {
                setState(() => _isDefault = value ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Nama printer harus diisi'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final config = PrinterConfig(
              id: const Uuid().v4(),
              name: _nameController.text,
              type: PrinterType.usb,
              paperSize: _selectedPaperSize,
              isDefault: _isDefault,
            );

            widget.onSave(config);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
