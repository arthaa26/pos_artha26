import 'package:flutter/material.dart';
import '../../models/receipt_template.dart';
import '../../services/receipt_template_service.dart';

class ReceiptTemplateSettingsPage extends StatefulWidget {
  const ReceiptTemplateSettingsPage({super.key});

  @override
  State<ReceiptTemplateSettingsPage> createState() =>
      _ReceiptTemplateSettingsPageState();
}

class _ReceiptTemplateSettingsPageState
    extends State<ReceiptTemplateSettingsPage> {
  final _templateService = ReceiptTemplateService();
  late List<ReceiptTemplate> _templates;
  ReceiptTemplate? _selectedTemplate;
  String _previewText = '';

  @override
  void initState() {
    super.initState();
    _templateService.initialize();
    _templates = _templateService.getAllTemplates();
    _selectedTemplate = _templateService.getActiveTemplate();
    _updatePreview();
  }

  void _updatePreview() {
    if (_selectedTemplate == null) return;

    // Sample data untuk preview
    final sampleData = <Map<String, dynamic>>[
      {
        'nama': 'Kopi',
        'jumlah': 1,
        'hargaSatuan': 25000.0,
        'subtotal': 25000.0,
      },
      {
        'nama': 'Nasi Goreng',
        'jumlah': 2,
        'hargaSatuan': 15000.0,
        'subtotal': 30000.0,
      },
    ];

    _previewText = _templateService.renderWithTemplate(
      template: _selectedTemplate!,
      storeName: 'TOKO ARTHA2B',
      storeAddress: 'Jl. Contoh No. 123',
      storePhone: '08123456789',
      items: sampleData,
      subtotal: 55000.0,
      ppnRate: 0.10,
      ppnAmount: 5500.0,
      grandTotal: 60500.0,
      cashGiven: 70000.0,
      change: 9500.0,
      transactionNumber: 'TRX20260124151438',
      transactionTime: DateTime.now(),
      cashierName: 'Admin',
    );

    setState(() {});
  }

  void _showEditDialog(ReceiptTemplate template) {
    final headerController = TextEditingController(text: template.headerTemplate);
    final itemController = TextEditingController(text: template.itemTemplate);
    final footerController = TextEditingController(text: template.footerTemplate);
    final nameController = TextEditingController(text: template.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit: ${template.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Template',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Variables:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TemplateVariables.getAllVariables()
                          .map(
                            (v) => Chip(
                              label: Text(v, style: const TextStyle(fontSize: 10)),
                              onDeleted: () {
                                // Copy variable to clipboard
                                final content = v;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Copied: $content')),
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Header template
              TextField(
                controller: headerController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Header Template',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: {centerAlign}{storeName}\n{storeAddress}...',
                ),
              ),
              const SizedBox(height: 12),

              // Item template
              TextField(
                controller: itemController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Item Template',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: {itemName:12}{itemQty:4}{itemTotal:>right}',
                ),
              ),
              const SizedBox(height: 12),

              // Footer template
              TextField(
                controller: footerController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Footer Template',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: {subtotalRow}\nTOTAL: {total}...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = template.copyWith(
                name: nameController.text,
                headerTemplate: headerController.text,
                itemTemplate: itemController.text,
                footerTemplate: footerController.text,
              );
              _templateService.updateTemplate(updated);

              setState(() {
                final index = _templates.indexWhere((t) => t.id == updated.id);
                if (index >= 0) {
                  _templates[index] = updated;
                }
                if (_selectedTemplate?.id == updated.id) {
                  _selectedTemplate = updated;
                  _updatePreview();
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Template Settings'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Template list
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                final isActive = _selectedTemplate?.id == template.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    selected: isActive,
                    title: Text(template.name),
                    subtitle: Text(
                      'Paper: ${template.paperWidth}mm',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isActive)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text('Active', style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () {
                                  _templateService
                                      .setActiveTemplate(template.id);
                                  _selectedTemplate = template;
                                  _updatePreview();
                                },
                                child: const Text('Activate'),
                              ),
                              PopupMenuItem(
                                onTap: () => _showEditDialog(template),
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Preview
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview: ${_selectedTemplate?.name ?? 'No Template'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectedTemplate != null
                            ? () => _showEditDialog(_selectedTemplate!)
                            : null,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: SelectableText(
                          _previewText,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
