class AppSettings {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String receiptHeader;
  final String receiptFooter;
  final bool receiptIncludeLogo;
  final double receiptFontSize;
  final String pinCode;
  final bool requirePinForProducts;
  final bool requirePinForCategories;
  final bool requirePinForExpenses;
  final bool requirePinForTransactions;
  final bool showProducts;
  final bool showCategories;
  final bool showExpenses;
  final bool showTransactions;
  final bool showReports;
  final bool showHistory;
  final bool showCashier;
  final double profitMargin;
  final String storeLogoPath;
  final double ppnRate;

  AppSettings({
    this.storeName = 'TOKO ARTHA26',
    this.storeAddress = 'Jl. Contoh No. 123',
    this.storePhone = '08123456789',
    this.receiptHeader = '',
    this.receiptFooter = '',
    this.receiptIncludeLogo = false,
    this.receiptFontSize = 12.0,
    this.pinCode = '1234',
    this.requirePinForProducts = false,
    this.requirePinForCategories = false,
    this.requirePinForExpenses = false,
    this.requirePinForTransactions = false,
    this.showProducts = true,
    this.showCategories = true,
    this.showExpenses = true,
    this.showTransactions = true,
    this.showReports = true,
    this.showHistory = true,
    this.showCashier = true,
    this.profitMargin = 0.2,
    this.storeLogoPath = '',
    this.ppnRate = 0.1,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      storeName: json['storeName'] ?? 'TOKO ARTHA26',
      storeAddress: json['storeAddress'] ?? 'Jl. Contoh No. 123',
      storePhone: json['storePhone'] ?? '08123456789',
      pinCode: json['pinCode'] ?? '1234',
      requirePinForProducts: json['requirePinForProducts'] ?? false,
      requirePinForCategories: json['requirePinForCategories'] ?? false,
      requirePinForExpenses: json['requirePinForExpenses'] ?? false,
      requirePinForTransactions: json['requirePinForTransactions'] ?? false,
      showProducts: json['showProducts'] ?? true,
      showCategories: json['showCategories'] ?? true,
      showExpenses: json['showExpenses'] ?? true,
      showTransactions: json['showTransactions'] ?? true,
      showReports: json['showReports'] ?? true,
      showHistory: json['showHistory'] ?? true,
      showCashier: json['showCashier'] ?? true,
      receiptHeader: json['receiptHeader'] ?? '',
      receiptFooter: json['receiptFooter'] ?? '',
      receiptIncludeLogo: json['receiptIncludeLogo'] ?? false,
      receiptFontSize: (json['receiptFontSize'] ?? 12.0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 0.2).toDouble(),
      storeLogoPath: json['storeLogoPath'] ?? '',
      ppnRate: (json['ppnRate'] ?? 0.1).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storePhone': storePhone,
      'receiptHeader': receiptHeader,
      'receiptFooter': receiptFooter,
      'receiptIncludeLogo': receiptIncludeLogo,
      'receiptFontSize': receiptFontSize,
      'pinCode': pinCode,
      'requirePinForProducts': requirePinForProducts,
      'requirePinForCategories': requirePinForCategories,
      'requirePinForExpenses': requirePinForExpenses,
      'requirePinForTransactions': requirePinForTransactions,
      'showProducts': showProducts,
      'showCategories': showCategories,
      'showExpenses': showExpenses,
      'showTransactions': showTransactions,
      'showReports': showReports,
      'showHistory': showHistory,
      'showCashier': showCashier,
      'profitMargin': profitMargin,
      'storeLogoPath': storeLogoPath,
      'ppnRate': ppnRate,
    };
  }

  AppSettings copyWith({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? receiptHeader,
    String? receiptFooter,
    bool? receiptIncludeLogo,
    double? receiptFontSize,
    String? storeLogoPath,
    String? pinCode,
    bool? requirePinForProducts,
    bool? requirePinForCategories,
    bool? requirePinForExpenses,
    bool? requirePinForTransactions,
    bool? showProducts,
    bool? showCategories,
    bool? showExpenses,
    bool? showTransactions,
    bool? showReports,
    bool? showHistory,
    bool? showCashier,
    double? profitMargin,
    double? ppnRate,
  }) {
    return AppSettings(
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      pinCode: pinCode ?? this.pinCode,
      requirePinForProducts:
          requirePinForProducts ?? this.requirePinForProducts,
      requirePinForCategories:
          requirePinForCategories ?? this.requirePinForCategories,
      requirePinForExpenses:
          requirePinForExpenses ?? this.requirePinForExpenses,
      requirePinForTransactions:
          requirePinForTransactions ?? this.requirePinForTransactions,
      showProducts: showProducts ?? this.showProducts,
      showCategories: showCategories ?? this.showCategories,
      showExpenses: showExpenses ?? this.showExpenses,
      showTransactions: showTransactions ?? this.showTransactions,
      showReports: showReports ?? this.showReports,
      showHistory: showHistory ?? this.showHistory,
      showCashier: showCashier ?? this.showCashier,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      receiptIncludeLogo: receiptIncludeLogo ?? this.receiptIncludeLogo,
      receiptFontSize: receiptFontSize ?? this.receiptFontSize,
      storeLogoPath: storeLogoPath ?? this.storeLogoPath,
      profitMargin: profitMargin ?? this.profitMargin,
      ppnRate: ppnRate ?? this.ppnRate,
    );
  }
}
