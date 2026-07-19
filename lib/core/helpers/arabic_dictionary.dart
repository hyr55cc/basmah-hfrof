import 'dart:convert';
import 'package:flutter/services.dart';
import 'arabic_text_helper.dart';

/// Arabic dictionary service
/// Loads words from bundled assets and provides fast O(1) lookups
class ArabicDictionary {
  ArabicDictionary._();

  static final ArabicDictionary instance = ArabicDictionary._();

  // Hash set for O(1) word lookup
  final Set<String> _words = <String>{};

  // Word frequency / score
  final Map<String, int> _wordScores = <String, int>{};

  // Length index: wordLength -> set of words
  final Map<int, Set<String>> _wordsByLength = <int, Set<String>>{};

  // Letter index: firstLetter -> set of words
  final Map<String, Set<String>> _wordsByFirstLetter = <String, Set<String>{};

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  int get wordCount => _words.length;

  /// Initialize the dictionary - call this on app start
  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      // Load the main dictionary
      final data = await rootBundle.loadString(
        'assets/dictionary/arabic_words.txt',
      );

      final lines = data.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        // Format: "word" or "word:score"
        final parts = trimmed.split(':');
        final word = ArabicTextHelper.normalize(parts[0].trim());
        if (word.isEmpty) continue;
        if (word.length < 2) continue; // Skip single letters

        _words.add(word);

        final score = parts.length > 1
            ? int.tryParse(parts[1].trim()) ?? 1
            : 1;
        _wordScores[word] = score;

        _wordsByLength.putIfAbsent(word.length, () => <String>{}).add(word);
        if (word.isNotEmpty) {
          _wordsByFirstLetter
              .putIfAbsent(word[0], () => <String>{})
              .add(word);
        }
      }

      _isLoaded = true;
    } catch (e) {
      // If asset not found, try loading from alternative path
      try {
        await _loadFromJson();
        _isLoaded = true;
      } catch (_) {
        // Last resort - load a built-in minimal dictionary
        _loadBuiltIn();
        _isLoaded = true;
      }
    }
  }

  Future<void> _loadFromJson() async {
    final data = await rootBundle.loadString(
      'assets/dictionary/arabic_words.json',
    );
    final List<dynamic> wordsList = json.decode(data) as List<dynamic>;
    for (final entry in wordsList) {
      if (entry is String) {
        final word = ArabicTextHelper.normalize(entry);
        if (word.isNotEmpty && word.length >= 2) {
          _words.add(word);
          _wordsByLength
              .putIfAbsent(word.length, () => <String>{})
              .add(word);
          if (word.isNotEmpty) {
            _wordsByFirstLetter
                .putIfAbsent(word[0], () => <String>{})
                .add(word);
          }
        }
      } else if (entry is Map<String, dynamic>) {
        final word = ArabicTextHelper.normalize(entry['word'] as String? ?? '');
        final score = entry['score'] as int? ?? 1;
        if (word.isNotEmpty && word.length >= 2) {
          _words.add(word);
          _wordScores[word] = score;
          _wordsByLength
              .putIfAbsent(word.length, () => <String>{})
              .add(word);
          if (word.isNotEmpty) {
            _wordsByFirstLetter
                .putIfAbsent(word[0], () => <String>{})
                .add(word);
          }
        }
      }
    }
  }

  /// Last-resort minimal dictionary baked into the app
  /// Common Arabic words for the game to work even without bundled assets
  void _loadBuiltIn() {
    const starter = <String>[
      // Family
      'أم', 'أب', 'ابن', 'بنت', 'أخ', 'أخت', 'عائلة', 'زوج', 'زوجة',
      'جد', 'جدة', 'حفيد', 'حفيدة', 'عم', 'عمة', 'خال', 'خالة',
      // Body
      'يد', 'رجل', 'رأس', 'عين', 'فم', 'أنف', 'أذن', 'شعر', 'قلب',
      'كبد', 'دم', 'عظم', 'جلد', 'سن', 'لسان', 'ظهر', 'بطن',
      // Nature
      'شمس', 'قمر', 'نجم', 'سماء', 'أرض', 'بحر', 'نهر', 'ماء', 'نار',
      'جبل', 'صحراء', 'غابة', 'شجرة', 'زهرة', 'نبات', 'حجر', 'رمل',
      'ثلج', 'مطر', 'سحاب', 'ريح', 'برق', 'رعد',
      // Animals
      'أسد', 'نمر', 'فيل', 'حصان', 'كلب', 'قطة', 'دجاجة', 'بقرة',
      'خروف', 'ماعز', 'جمل', 'غزال', 'صقر', 'حمامة', 'نحلة', 'فراشة',
      'سمكة', 'دلفين', 'حوت', 'قرد', 'دب', 'أرنب', 'فأر', 'سلحفاة',
      // Food
      'خبز', 'لحم', 'دجاج', 'سمك', 'أرز', 'حليب', 'جبنة', 'زبدة',
      'بيض', 'فاكهة', 'تفاح', 'برتقال', 'موز', 'عنب', 'تمر', 'خوخ',
      'خضار', 'طماطم', 'خيار', 'بصل', 'ثوم', 'جزر', 'بطاطس', 'بقدونس',
      'نعناع', 'زعتر', 'كركم', 'زنجبيل', 'فلفل', 'ملح', 'سكر', 'عسل',
      // Drinks
      'شاي', 'قهوة', 'عصير', 'ماء', 'حليب', 'لبن',
      // Colors
      'أحمر', 'أزرق', 'أخضر', 'أصفر', 'أبيض', 'أسود', 'بنفسجي',
      'وردي', 'بني', 'رمادي', 'ذهبي', 'فضي', 'برتقالي',
      // Numbers
      'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية',
      'تسعة', 'عشرة', 'مئة', 'ألف', 'مليون',
      // Days / Time
      'يوم', 'ليلة', 'صباح', 'مساء', 'ظهر', 'عصر', 'فجر', 'غروب',
      'أسبوع', 'شهر', 'سنة', 'ساعة', 'دقيقة', 'ثانية', 'لحظة',
      'أمس', 'غدا', 'اليوم',
      'السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة',
      'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو', 'يوليو',
      'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
      // Places
      'بيت', 'منزل', 'غرفة', 'مطبخ', 'حمام', 'صالة', 'حديقة', 'شارع',
      'مدينة', 'قرية', 'بلد', 'دولة', 'قارة', 'عالم', 'مدرسة', 'جامعة',
      'مستشفى', 'مطار', 'ميناء', 'محطة', 'فندق', 'مطعم', 'متجر', 'سوق',
      'مسجد', 'كنيسة', 'مكتبة', 'متحف', 'ملعب', 'حديقة',
      // Buildings
      'قصر', 'برج', 'جسر', 'سور', 'باب', 'نافذة', 'سقف', 'أرضية',
      'حائط', 'درج', 'مصعد', 'قبو', 'سطح',
      // Transportation
      'سيارة', 'حافلة', 'قطار', 'طائرة', 'سفينة', 'قارب', 'دراجة',
      'دراجة_نارية', 'تاكسي', 'مترو', 'ترام', 'صاروخ',
      // Countries / Cities
      'مصر', 'السعودية', 'الإمارات', 'الكويت', 'قطر', 'البحرين', 'عمان',
      'الأردن', 'لبنان', 'سوريا', 'فلسطين', 'العراق', 'اليمن', 'ليبيا',
      'تونس', 'الجزائر', 'المغرب', 'السودان', 'موريتانيا', 'الصومال',
      'جيبوتي', 'قبرص',
      'القاهرة', 'الرياض', 'جدة', 'مكة', 'المدينة', 'الدمام', 'دبي',
      'أبوظبي', 'الدوحة', 'الكويت', 'المنامة', 'مسقط', 'عمان', 'بيروت',
      'دمشق', 'بغداد', 'صنعاء', 'تونس', 'الجزائر', 'الرباط', 'الخرطوم',
      'باريس', 'لندن', 'نيويورك', 'واشنطن', 'طوكيو', 'بكين', 'موسكو',
      'روما', 'مدريد', 'برلين', 'اسطنبول',
      // Religion
      'إسلام', 'مسلم', 'مؤمن', 'صلاة', 'صوم', 'زكاة', 'حج', 'عمرة',
      'قرآن', 'سنة', 'حديث', 'دعاء', 'ذكر', 'تسبيح', 'حمد', 'شكر',
      'توحيد', 'إيمان', 'تقوى', 'صبر', 'رحمة', 'مغفرة', 'جنة', 'نار',
      'ملائكة', 'نبي', 'رسول', 'إمام', 'خطيب', 'مؤذن', 'فقيه', 'عالم',
      'مسجد', 'محراب', 'منبر', 'قبلة', 'وضوء', 'تيمم', 'أذان', 'إقامة',
      // Common verbs (past tense)
      'كتب', 'قرأ', 'درس', 'فهم', 'حفظ', 'نظر', 'سمع', 'أكل', 'شرب',
      'نام', 'استيقظ', 'ذهب', 'رجع', 'جاء', 'مشى', 'ركض', 'قفز',
      'جلس', 'وقف', 'فعل', 'عمل', 'لعب', 'ضحك', 'بكى', 'فرح', 'حزن',
      'أحب', 'كره', 'عرف', 'جهل', 'علم', 'تعلم', 'فكر', 'تذكر', 'نسي',
      'فتح', 'أغلق', 'دخل', 'خرج', 'صعد', 'نزل', 'طار', 'سقط',
      'بنى', 'هدم', 'زرع', 'حصد', 'طبخ', 'أعد', 'كسر', 'صلح',
      'ربح', 'خسر', 'أعطى', 'أخذ', 'باع', 'اشترى', 'دفع', 'قبض',
      // Common adjectives
      'كبير', 'صغير', 'طويل', 'قصير', 'جميل', 'قبيح', 'جديد', 'قديم',
      'سعيد', 'حزين', 'غني', 'فقير', 'قوي', 'ضعيف', 'سريع', 'بطيء',
      'ذكي', 'غبي', 'طيب', 'خبيث', 'صادق', 'كاذب', 'أمين', 'خائن',
      'حار', 'بارد', 'دافئ', 'رطب', 'جاف', 'ناعم', 'خشن', 'حاد',
      'ثمين', 'رخيص', 'نادر', 'شائع', 'ممكن', 'مستحيل', 'سهل', 'صعب',
      'ممتع', 'ممل', 'خطير', 'آمن', 'صحيح', 'مريض', 'سليم',
      // Professions
      'طبيب', 'مهندس', 'معلم', 'أستاذ', 'مدير', 'موظف', 'عامل', 'فلاح',
      'تاجر', 'محامي', 'قاضي', 'شرطي', 'جندي', 'ضابط', 'طيار', 'بحار',
      'كاتب', 'صحفي', 'مذيع', 'ممثل', 'فنان', 'رسام', 'موسيقي', 'شاعر',
      'كهربائي', 'سباك', 'نجار', 'حداد', 'خياط', 'حلاق', 'طباخ', 'نادل',
      // School / Education
      'كتاب', 'قلم', 'دفتر', 'مسطرة', 'ممحاة', 'حقيبة', 'مدرسة', 'صف',
      'درس', 'مادة', 'رياضيات', 'علوم', 'لغة', 'عربية', 'إنجليزية',
      'تاريخ', 'جغرافيا', 'فن', 'موسيقى', 'رياضة', 'جامعة', 'كلية',
      'معهد', 'شهادة', 'دبلوم', 'بكالوريوس', 'ماجستير', 'دكتوراه',
      'امتحان', 'نتيجة', 'نجاح', 'رسوب', 'تفوق', 'إجابة', 'سؤال',
      // Tech
      'هاتف', 'جوال', 'حاسوب', 'شاشة', 'لوحة', 'ماوس', 'طابعة', 'إنترنت',
      'موقع', 'تطبيق', 'برنامج', 'لعبة', 'فيديو', 'صورة', 'صوت', 'موسيقى',
      'بريد', 'رسالة', 'محادثة', 'اتصال', 'شبكة', 'سيرفر', 'بيانات',
      // House
      'سرير', 'كرسي', 'طاولة', 'مكتب', 'خزانة', 'رف', 'مرآة', 'مصباح',
      'سجادة', 'وسادة', 'بطانية', 'ملاءة', 'منشفة', 'صابون', 'شامبو',
      'فرشاة', 'مشط', 'مفتاح', 'قفل',
      // Money
      'مال', 'درهم', 'دينار', 'ريال', 'جنيه', 'دولار', 'يورو', 'ين',
      'عملة', 'بنك', 'صراف', 'فائدة', 'ربح', 'خسارة', 'سعر', 'ثمن',
      // Travel
      'رحلة', 'سياحة', 'سفر', 'إجازة', 'عطلة', 'تأشيرة', 'جواز',
      'حقيبة', 'خيمة', 'فندق', 'استراحة', 'طريق', 'خريطة', 'بوصلة',
      'معلم', 'أثر', 'متحف', 'معرض', 'مهرجان', 'احتفال',
      // Body actions
      'تنفس', 'زفير', 'شهيق', 'نظرة', 'ابتسامة', 'ضحكة', 'بصمة', 'لمسة',
      'صوت', 'همس', 'صراخ', 'صفير', 'صفق', 'تصفيق',
      // Food items
      'شاورما', 'فلافل', 'حمص', 'تبولة', 'متبل', 'فتوش', 'كبسة', 'مندي',
      'مظبي', 'برياني', 'كشري', 'ملوخية', 'بامية', 'فول', 'شكشوكة',
      'عصيدة', 'هريسة', 'كنافة', 'بقلاوة', 'قطايف', 'مهلبية', 'أم علي',
      'بسبوسة', 'لقيمات', 'زلابية',
      // Sports
      'كرة', 'قدم', 'سلة', 'طائرة', 'يد', 'تنس', 'جولف', 'سباحة',
      'جري', 'قفز', 'ملاكمة', 'مصارعة', 'جمباز', 'تزلج', 'تسلق',
      'فريق', 'لاعب', 'مدرب', 'حكم', 'جمهور', 'ملعب', 'هدف', 'نقطة',
      'فوز', 'تعادل', 'هزيمة', 'بطولة', 'دوري', 'كأس', 'ميدالية',
      // Music
      'عود', 'طبل', 'ناي', 'كمان', 'بيانو', 'جيتار', 'فلوت', 'هارمونيكا',
      'أغنية', 'لحن', 'إيقاع', 'نغمة', 'صوت', 'همس', 'صفير',
      // Islamic
      'بسم_الله', 'الحمد_لله', 'سبحان_الله', 'الله_أكبر', 'لا_إله_إلا_الله',
      'أستغفر_الله', 'لا_حول_ولا_قوة', 'ما_شاء_الله', 'بارك_الله',
      'السلام_عليكم', 'ورحمة_الله', 'وبركاته', 'عليه_السلام',
      'رضي_الله_عنه', 'صلى_الله_عليه_وسلم', 'الفاتحة',
      'البقرة', 'آل_عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف',
      'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
      'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه', 'الأنبياء', 'الحج',
      'المؤمنون', 'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص',
      'العنكبوت', 'الروم', 'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر',
      'يس', 'الصافات', 'ص', 'الزمر', 'غافر', 'فصلت', 'الشورى',
      'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف', 'محمد', 'الفتح',
      'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن',
      'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة', 'الصف',
      'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك',
      'القلم', 'الحاقة', 'المعارج', 'نوح', 'الجن', 'المزمل', 'المدثر',
      'القيامة', 'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
      'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج', 'الطارق',
      'الأعلى', 'الغاشية', 'الفجر', 'البلد', 'الشمس', 'الليل', 'الضحى',
      'الشرح', 'التين', 'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
      'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل', 'قريش', 'الماعون',
      'الكوثر', 'الكافرون', 'النصر', 'المسد', 'الإخلاص', 'الفلق', 'الناس',
      // Other common
      'حياة', 'موت', 'سلام', 'حرب', 'عدل', 'ظلم', 'حق', 'باطل',
      'صدق', 'كذب', 'حب', 'كره', 'أمل', 'يأس', 'فرح', 'حزن', 'غضب',
      'خوف', 'أمان', 'حرية', 'عبودية', 'قوة', 'ضعف', 'نصر', 'هزيمة',
      'بداية', 'نهاية', 'وسط', 'طرف', 'داخل', 'خارج', 'فوق', 'تحت',
      'يمين', 'شمال', 'أمام', 'خلف', 'قريب', 'بعيد', 'كثير', 'قليل',
      'كل', 'بعض', 'لا_شيء', 'شيء', 'حقيقة', 'خيال', 'وهم', 'يقين',
      'سر', 'علن', 'ظاهر', 'باطل', 'حلال', 'حرام', 'طيب', 'خبيث',
    ];
    for (final word in starter) {
      final normalized = ArabicTextHelper.normalize(word);
      _words.add(normalized);
      _wordsByLength
          .putIfAbsent(normalized.length, () => <String>{})
          .add(normalized);
      if (normalized.isNotEmpty) {
        _wordsByFirstLetter
            .putIfAbsent(normalized[0], () => <String>{})
            .add(normalized);
      }
    }
  }

  /// Check if a word exists in the dictionary
  bool contains(String word) {
    if (!_isLoaded) return false;
    return _words.contains(ArabicTextHelper.normalize(word));
  }

  /// Get the score / frequency of a word
  int getScore(String word) {
    if (!_isLoaded) return 0;
    return _wordScores[ArabicTextHelper.normalize(word)] ?? 1;
  }

  /// Get all words of a specific length
  Set<String> getWordsByLength(int length) {
    if (!_isLoaded) return <String>{};
    return _wordsByLength[length] ?? <String>{};
  }

  /// Get all words starting with a letter
  Set<String> getWordsByFirstLetter(String letter) {
    if (!_isLoaded) return <String>{};
    final normalized = ArabicTextHelper.normalize(letter);
    return _wordsByFirstLetter[normalized] ?? <String>{};
  }

  /// Get all possible words that can be formed from a set of letters
  /// (used for hint system, valid word suggestions)
  List<String> findPossibleWords(List<String> letters, {int? minLength}) {
    if (!_isLoaded) return <String>[];
    final result = <String>[];
    final min = minLength ?? 3;
    final unique = letters.toSet();
    for (final word in _words) {
      if (word.length < min) continue;
      if (word.length > letters.length) continue;
      if (ArabicTextHelper.wordCanBeFormedFrom(word, letters)) {
        result.add(word);
      }
    }
    return result;
  }

  /// Quick check if word is valid Arabic
  bool isValidArabicWord(String word) {
    if (word.isEmpty) return false;
    if (!ArabicTextHelper.isArabic(word)) return false;
    if (word.length < 2) return false;
    return contains(word);
  }

  /// Get random word from dictionary of given length
  String? getRandomWord(int length) {
    if (!_isLoaded) return null;
    final words = _wordsByLength[length];
    if (words == null || words.isEmpty) return null;
    final list = words.toList();
    list.shuffle();
    return list.first;
  }

  /// Get total word count for stats
  Map<String, int> getStats() {
    return {
      'total': _words.length,
      'lengths': _wordsByLength.length,
    };
  }
}
