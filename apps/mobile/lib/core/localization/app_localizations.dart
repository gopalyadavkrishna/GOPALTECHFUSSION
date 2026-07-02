import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) => state = locale;
}

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
    Locale('gu'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _values = <String, Map<String, String>>{
    'en': {
      'appName': 'Power Alert',
      'tagline': 'Stay Informed. Stay Powered.',
      'continueLabel': 'Continue',
      'home': 'Home',
      'outages': 'Outages',
      'map': 'Map',
      'report': 'Report',
      'alerts': 'Alerts',
      'powerAvailable': 'Power Available',
      'powerOutage': 'Power Outage',
      'maintenance': 'Maintenance',
      'emergency': 'Emergency',
      'quickActions': 'Quick actions',
      'activeOutages': 'Active outages',
      'viewDetails': 'View details',
      'estimatedRestore': 'Estimated restoration',
      'reportIssue': 'Report an issue',
      'submitComplaint': 'Submit complaint',
      'language': 'Language',
      'theme': 'Theme',
    },
    'hi': {
      'appName': 'पावर अलर्ट',
      'tagline': 'जानकारी रखें। बिजली से जुड़े रहें।',
      'continueLabel': 'जारी रखें',
      'home': 'होम',
      'outages': 'बिजली कटौती',
      'map': 'मानचित्र',
      'report': 'शिकायत',
      'alerts': 'अलर्ट',
      'powerAvailable': 'बिजली उपलब्ध',
      'powerOutage': 'बिजली बंद',
      'maintenance': 'रखरखाव',
      'emergency': 'आपातकाल',
      'quickActions': 'त्वरित कार्य',
      'activeOutages': 'सक्रिय कटौती',
      'viewDetails': 'विवरण देखें',
      'estimatedRestore': 'अनुमानित बहाली',
      'reportIssue': 'समस्या दर्ज करें',
      'submitComplaint': 'शिकायत भेजें',
      'language': 'भाषा',
      'theme': 'थीम',
    },
    'bn': {
      'appName': 'পাওয়ার অ্যালার্ট',
      'tagline': 'সচেতন থাকুন। বিদ্যুৎ সংযুক্ত থাকুন।',
      'continueLabel': 'এগিয়ে যান',
      'home': 'হোম',
      'outages': 'বিদ্যুৎ বিভ্রাট',
      'map': 'মানচিত্র',
      'report': 'অভিযোগ',
      'alerts': 'সতর্কতা',
      'powerAvailable': 'বিদ্যুৎ আছে',
      'powerOutage': 'বিদ্যুৎ নেই',
      'maintenance': 'রক্ষণাবেক্ষণ',
      'emergency': 'জরুরি',
      'quickActions': 'দ্রুত কাজ',
      'activeOutages': 'সক্রিয় বিভ্রাট',
      'viewDetails': 'বিস্তারিত দেখুন',
      'estimatedRestore': 'সম্ভাব্য পুনরুদ্ধার',
      'reportIssue': 'সমস্যা জানান',
      'submitComplaint': 'অভিযোগ জমা দিন',
      'language': 'ভাষা',
      'theme': 'থিম',
    },
    'mr': {
      'appName': 'पॉवर अलर्ट',
      'tagline': 'माहित रहा. ऊर्जित रहा.',
      'continueLabel': 'पुढे जा',
      'home': 'मुख्यपृष्ठ',
      'outages': 'वीज खंडित',
      'map': 'नकाशा',
      'report': 'तक्रार',
      'alerts': 'सूचना',
      'powerAvailable': 'वीज उपलब्ध',
      'powerOutage': 'वीज बंद',
      'maintenance': 'देखभाल',
      'emergency': 'आणीबाणी',
      'quickActions': 'त्वरित कृती',
      'activeOutages': 'सक्रिय वीज खंडित',
      'viewDetails': 'तपशील पहा',
      'estimatedRestore': 'अंदाजित पूर्ववत वेळ',
      'reportIssue': 'समस्या नोंदवा',
      'submitComplaint': 'तक्रार पाठवा',
      'language': 'भाषा',
      'theme': 'थीम',
    },
    'ta': {
      'appName': 'பவர் அலர்ட்',
      'tagline': 'தகவலுடன் இருங்கள். மின்சாரத்துடன் இருங்கள்.',
      'continueLabel': 'தொடரவும்',
      'home': 'முகப்பு',
      'outages': 'மின்தடை',
      'map': 'வரைபடம்',
      'report': 'புகார்',
      'alerts': 'அறிவிப்புகள்',
      'powerAvailable': 'மின்சாரம் உள்ளது',
      'powerOutage': 'மின்தடை',
      'maintenance': 'பராமரிப்பு',
      'emergency': 'அவசரம்',
      'quickActions': 'விரைவு செயல்கள்',
      'activeOutages': 'செயலில் உள்ள மின்தடைகள்',
      'viewDetails': 'விவரங்களைக் காண்க',
      'estimatedRestore': 'மீட்பு மதிப்பீடு',
      'reportIssue': 'சிக்கலைப் புகாரளிக்கவும்',
      'submitComplaint': 'புகாரை சமர்ப்பிக்கவும்',
      'language': 'மொழி',
      'theme': 'தீம்',
    },
    'te': {
      'appName': 'పవర్ అలర్ట్',
      'tagline': 'సమాచారంతో ఉండండి. విద్యుత్తుతో ఉండండి.',
      'continueLabel': 'కొనసాగించండి',
      'home': 'హోమ్',
      'outages': 'విద్యుత్ అంతరాయం',
      'map': 'మ్యాప్',
      'report': 'ఫిర్యాదు',
      'alerts': 'హెచ్చరికలు',
      'powerAvailable': 'విద్యుత్ అందుబాటులో ఉంది',
      'powerOutage': 'విద్యుత్ లేదు',
      'maintenance': 'నిర్వహణ',
      'emergency': 'అత్యవసరం',
      'quickActions': 'త్వరిత చర్యలు',
      'activeOutages': 'క్రియాశీల అంతరాయాలు',
      'viewDetails': 'వివరాలు చూడండి',
      'estimatedRestore': 'అంచనా పునరుద్ధరణ',
      'reportIssue': 'సమస్యను నివేదించండి',
      'submitComplaint': 'ఫిర్యాదు సమర్పించండి',
      'language': 'భాష',
      'theme': 'థీమ్',
    },
    'gu': {
      'appName': 'પાવર એલર્ટ',
      'tagline': 'માહિતગાર રહો. પાવર સાથે રહો.',
      'continueLabel': 'આગળ વધો',
      'home': 'હોમ',
      'outages': 'વીજ વિક્ષેપ',
      'map': 'નકશો',
      'report': 'ફરિયાદ',
      'alerts': 'ચેતવણીઓ',
      'powerAvailable': 'વીજળી ઉપલબ્ધ',
      'powerOutage': 'વીજળી બંધ',
      'maintenance': 'જાળવણી',
      'emergency': 'કટોકટી',
      'quickActions': 'ઝડપી કાર્યો',
      'activeOutages': 'સક્રિય વિક્ષેપ',
      'viewDetails': 'વિગતો જુઓ',
      'estimatedRestore': 'અંદાજિત પુનઃસ્થાપન',
      'reportIssue': 'સમસ્યા નોંધાવો',
      'submitComplaint': 'ફરિયાદ મોકલો',
      'language': 'ભાષા',
      'theme': 'થીમ',
    },
  };

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
