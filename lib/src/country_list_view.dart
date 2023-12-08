import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:openim_common/openim_common.dart';

import 'country.dart';
import 'country_list_theme_data.dart';
import 'country_localizations.dart';
import 'country_service.dart';
import 'res/country_codes.dart';
import 'utils.dart';

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// An optional argument for showing "World Wide" option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for hiding the search bar
  final bool showSearch;

  /// An optional argument for hiding the auto locate button
  final bool showAutoLocate;

  const CountryListView({
    Key? key,
    required this.onSelect,
    this.exclude,
    this.favorite,
    this.countryFilter,
    this.showPhoneCode = false,
    this.countryListTheme,
    this.searchAutofocus = false,
    this.showWorldWide = false,
    this.showSearch = true,
    this.showAutoLocate = true,
  })  : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        ),
        super(key: key);

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  final CountryService _countryService = CountryService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Country> _countryList;
  late List<Country> _filteredList;
  List<Country>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;
  bool checkSorting = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _countryList = _countryService.getAll();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    //Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.favorite != null) {
      _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => widget.exclude!.contains(element.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) => !widget.countryFilter!.contains(element.countryCode),
      );
    }

    _filteredList = <Country>[];
    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  void sortFilter({
    required Locale locale,
    required List<Country> countries,
    required CountryLocalizations? localizations,
  }) {
    /// check sorting to prevent the widget build to call this function multiple time
    checkSorting = true;
    if (localizations == null) return;

    switch (locale.countryCode) {
      case 'TW':
      case 'CN':
        _filteredList = List.from(countries)
          ..sort((a, b) {
            final localizedCountryNameA = CountryLocalizations.of(context)
                ?.countryName(countryCode: a.countryCode);
            final localizedCountryNameB = CountryLocalizations.of(context)
                ?.countryName(countryCode: b.countryCode);

            // Logger.print("Short Pinyin A: $localizedCountryNameA");
            // Logger.print("Short Pinyin B: $localizedCountryNameB");

            if (localizedCountryNameA != null &&
                localizedCountryNameB != null) {
              return PinyinHelper.getShortPinyin(localizedCountryNameA)
                  .compareTo(
                      PinyinHelper.getShortPinyin(localizedCountryNameB));
            } else {
              Logger.print(
                  "Failed to get localized country name for ${a.name} or ${b.name}");
              return 0; // Handle the case where localization fails; you may want to customize this behavior.
            }
          });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!checkSorting) {
      final appLocale =
          CountryLocalizations.of(context)?.locale ?? const Locale('en', 'US');
      Logger.print("creturn locale code ${appLocale.countryCode} ");
      sortFilter(
        locale: appLocale,
        countries: _filteredList,
        localizations: CountryLocalizations.of(context),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.showSearch)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: TextField(
                  autofocus: _searchAutofocus,
                  controller: _searchController,
                  style: widget.countryListTheme?.searchTextStyle ??
                      _defaultTextStyle,
                  decoration: widget.countryListTheme?.inputDecoration ??
                      InputDecoration(
                        labelText: StrRes.countrypickerSdkSearch,
                        hintText: StrRes.countrypickerSdkSearch,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF8C98A8).withOpacity(0.2),
                          ),
                        ),
                      ),
                  onChanged: _filterSearchResults,
                ),
              ),
            if (widget.showAutoLocate)
              Column(
                children: [
                  SizedBox(
                      width: 80,
                      child: Divider(thickness: 2, color: Styles.c_C2C2C2)),
                  const SizedBox(height: 14),
                  StrRes.countrypickerSdkAutoLocateLabel.toText
                    ..style = Styles.ts_000000_22sp_regular_montserrat,
                  const SizedBox(height: 14),
                  Button(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    radius: 5.0,
                    gradient: Styles.linear_gradient_000000_828282,
                    boxShadow: Styles.box_shadow_btn,
                    text: StrRes.countrypickerSdkAutoLocateButton,
                    textStyle: Styles.ts_FFFFFF_14sp,
                    onTap: _getStateNumber,
                  ),
                ],
              ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: ListView(
                  children: [
                    if (_favoriteList != null) ...[
                      ..._favoriteList!
                          .map<Widget>((currency) => _listRow(currency))
                          .toList(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(thickness: 1),
                      ),
                    ],
                    ..._filteredList
                        .map<Widget>((country) => _listRow(country))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          selectCountry(country);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: (CountryLocalizations.of(context)
                                ?.countryName(countryCode: country.countryCode)
                                ?.replaceAll(RegExp(r"\s+"), " ") ??
                            country.name)
                        .toText
                      ..overflow = TextOverflow.ellipsis
                      ..maxLines = 2,
                  ),
                  Row(
                    children: [
                      // _flagWidget(country),
                      if (widget.showPhoneCode && !country.iswWorldWide) ...[
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
                            style: Styles.ts_000000_16sp_regular_montserrat,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ] else
                        const SizedBox(width: 15),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _flagWidget(Country country) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: Text(
        country.iswWorldWide
            ? '\uD83C\uDF0D'
            : Utils.countryCodeToEmoji(country.countryCode),
        style: TextStyle(
          fontSize: widget.countryListTheme?.flagSize ?? 25,
        ),
      ),
    );
  }

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
          .where((c) => c.startsWith(query, localizations))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  void selectCountry(Country country) {
    country.nameLocalized = CountryLocalizations.of(context)
        ?.countryName(countryCode: country.countryCode)
        ?.replaceAll(RegExp(r"\s+"), " ");
    widget.onSelect(country);
    Navigator.pop(context);
  }

  Future<void> _autoLocate() async {
    final pos = await _getCurrentPosition();
    final place = await _getCountryPrefix(pos);
    final isoCountryCode = place?.isoCountryCode ?? "US";
    final country = _countryService.findByCode(isoCountryCode);

    if (!context.mounted) return;

    if (country != null) {
      country.nameLocalized = CountryLocalizations.of(context)
          ?.countryName(countryCode: country.countryCode)
          ?.replaceAll(RegExp(r"\s+"), " ");
      widget.onSelect(country);
    }
    Navigator.pop(context);
  }

  Future<void> _getStateNumber() =>
      LoadingView.singleton.wrap(asyncFunction: () => _autoLocate());

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (Platform.isIOS) {
        await Geolocator.openAppSettings();
      } else if (Platform.isAndroid) {
        //  await Geolocator.openAppSettings();
        await Geolocator.openLocationSettings();
      }
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      final currPos = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 15),
      );
      // Logger.print("creturn ${jsonEncode(currPos)}");
      return currPos;
    } catch (error, stack) {
      final String timeOutAlert = CountryLocalizations.of(
                  _scaffoldKey.currentContext!)
              ?.countryName(countryCode: 'timeoutAlert') ??
          'Could not find your location. Please check your connection and try again.';
      Logger.print('$error $stack');
      IMViews.showToast(timeOutAlert);
      return Future.error('Location Time out');
    }
  }

  Future<Placemark?> _getCountryPrefix(Position position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      final placemark = placemarks[0];
      Logger.print("creturn ${jsonEncode(placemark)}");
      return placemark;
    }
    return null;
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
