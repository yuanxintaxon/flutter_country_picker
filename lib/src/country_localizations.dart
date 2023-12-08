import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';

import 'res/strings/ar.dart';
import 'res/strings/cn.dart';
import 'res/strings/cs.dart';
import 'res/strings/de.dart';
import 'res/strings/en.dart';
import 'res/strings/es.dart';
import 'res/strings/et.dart';
import 'res/strings/fr.dart';
import 'res/strings/gr.dart';
import 'res/strings/hr.dart';
import 'res/strings/it.dart';
import 'res/strings/ku.dart';
import 'res/strings/lt.dart';
import 'res/strings/lv.dart';
import 'res/strings/nb.dart';
import 'res/strings/nl.dart';
import 'res/strings/nn.dart';
import 'res/strings/np.dart';
import 'res/strings/pl.dart';
import 'res/strings/pt.dart';
import 'res/strings/ru.dart';
import 'res/strings/tr.dart';
import 'res/strings/tw.dart';
import 'res/strings/uk.dart';

class CountryLocalizations {
  final Locale locale;

  CountryLocalizations(this.locale);

  /// The `CountryLocalizations` from the closest [Localizations] instance
  /// that encloses the given context.
  ///
  /// This method is just a convenient shorthand for:
  /// `Localizations.of<CountryLocalizations>(context, CountryLocalizations)`.
  ///
  /// References to the localized resources defined by this class are typically
  /// written in terms of this method. For example:
  ///
  /// ```dart
  /// CountryLocalizations.of(context).countryName(key: country.key),
  /// ```
  static CountryLocalizations? of(BuildContext context) {
    return Localizations.of<CountryLocalizations>(
      context,
      CountryLocalizations,
    );
  }

  /// A [LocalizationsDelegate] that uses [_CountryLocalizationsDelegate.load]
  /// to create an instance of this class.
  static const LocalizationsDelegate<CountryLocalizations> delegate =
      _CountryLocalizationsDelegate();

  /// The localized country name for the given country code.
  String? countryName({required String key}) {
    switch (locale.countryCode?.toLowerCase()) {
      case 'cn':
        return cn[key];
      case 'tw':
        return tw[key];
      case 'el':
        return gr[key];
      case 'es':
        return es[key];
      case 'et':
        return et[key];
      case 'pt':
        return pt[key];
      case 'nb':
        return nb[key];
      case 'nn':
        return nn[key];
      case 'uk':
        return uk[key];
      case 'pl':
        return pl[key];
      case 'tr':
        return tr[key];
      case 'ru':
        return ru[key];
      case 'hi':
      case 'ne':
        return np[key];
      case 'ar':
        return ar[key];
      case 'ku':
        return ku[key];
      case 'hr':
        return hr[key];
      case 'fr':
        return fr[key];
      case 'de':
        return de[key];
      case 'lv':
        return lv[key];
      case 'lt':
        return lt[key];
      case 'nl':
        return nl[key];
      case 'it':
        return it[countryCode];
      case 'ko':
        return ko[countryCode];
      case 'ja':
        return ja[countryCode];
      case 'id':
        return id[countryCode];
      case 'cs':
        return cs[countryCode];
      case 'en':
      default:
        return en[key];
    }
  }
}

class _CountryLocalizationsDelegate
    extends LocalizationsDelegate<CountryLocalizations> {
  const _CountryLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'ar',
      'ku',
      'zh',
      'el',
      'es',
      'et',
      'pl',
      'pt',
      'nb',
      'nn',
      'ru',
      'uk',
      'hi',
      'ne',
      'tr',
      'hr',
      'fr',
      'de',
      'lt',
      'lv',
      'nl',
      'it',
      'ko',
      'ja',
      'id',
      'cs',
    ].contains(locale.languageCode);
  }

  @override
  Future<CountryLocalizations> load(Locale locale) {
    final CountryLocalizations localizations = CountryLocalizations(locale);
    return Future.value(localizations);
  }

  @override
  bool shouldReload(_CountryLocalizationsDelegate old) => false;
}
