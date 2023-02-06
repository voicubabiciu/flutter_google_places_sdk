import 'package:flutter_google_places_sdk_macos/types/place_details/address_component.dart';
import 'package:flutter_google_places_sdk_macos/types/place_details/business_status.dart';
import 'package:flutter_google_places_sdk_macos/types/place_details/geometry.dart';
import 'package:flutter_google_places_sdk_macos/types/place_details/opening_hours.dart';
import 'package:flutter_google_places_sdk_macos/types/place_details/photo_metadata.dart';
import 'package:flutter_google_places_sdk_macos/types/place_details/place_type.dart';
import 'package:flutter_google_places_sdk_macos/types/place_details/plus_code.dart';
import 'package:flutter_google_places_sdk_platform_interface/flutter_google_places_sdk_platform_interface.dart'
    as intern;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

/// Represents a particular physical place.
///
/// A Place encapsulates information about a physical location, including its name, address, and any other information we might have about it.
///
/// Note: In general, some fields will be inapplicable to certain places, or the information may not exist.
///
/// Ref: https://developers.google.com/maps/documentation/places/android-sdk/reference/com/google/android/libraries/places/api/model/Place
@freezed
class Place with _$Place {
  const Place._();
  const factory Place({
    @JsonKey(name: 'address_components')
    @Default([])
        List<AddressComponent> addressComponents,
    @JsonKey(name: 'business_status') BusinessStatus? businessStatus,
    @JsonKey(name: 'html_attributions') @Default([]) List<String> attributions,
    @JsonKey(name: 'formatted_address') String? formattedAddress,
    @JsonKey(name: 'formatted_phone_number') String? formattedPhoneNumber,
    Geometry? geometry,
    String? icon,
    String? name,
    @JsonKey(name: 'opening_hours') OpeningHours? openingHours,
    @Default([]) List<PlacePhoto> photos,
    @JsonKey(name: 'palce_id') String? placeId,
    @JsonKey(name: 'plus_code') PlusCode? plusCode,
    @JsonKey(name: 'price_level') required int? priceLevel,
    double? rating,
    @Default(false) bool reservable,
    @Default([]) List<PlaceType> types,
    @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
    @JsonKey(name: 'utc_offset') int? utcOffsetMinutes,
    Uri? websiteUri,
  }) = _Place;

  intern.Place toInterface() {
    return intern.Place(
      addressComponents: addressComponents
          .map((e) => intern.AddressComponent(
              name: e.name, shortName: e.shortName, types: e.types))
          .toList(),
      businessStatus: businessStatus == null
          ? null
          : intern.BusinessStatus.values[businessStatus!.index],
      address: formattedAddress,
      attributions: attributions,
      latLng: intern.LatLng(
          lat: geometry?.location?.lat ?? -180,
          lng: geometry?.location?.lng ?? -180),
      name: name,
      openingHours: _parseOpeningHours(),
      phoneNumber: formattedPhoneNumber,
      photoMetadatas: photos
          .map((e) => intern.PhotoMetadata(
                height: e.height,
                width: e.width,
                attributions: e.attributions.reduce((a, b) => '$a|$b'),
                photoReference: e.photoReference,
              ))
          .toList(),
      plusCode: intern.PlusCode(
        compoundCode: plusCode?.compoundCode ?? '',
        globalCode: plusCode?.globalCode ?? '',
      ),
      priceLevel: priceLevel,
      rating: rating,
      types: types.map((e) {
        return intern.PlaceType.values[e.index];
      }).toList(),
      viewport: intern.LatLngBounds(
        northeast: intern.LatLng(
          lat: geometry?.viewport?.northeast.lat ?? -180,
          lng: geometry?.viewport?.northeast.lng ?? -180,
        ),
        southwest: intern.LatLng(
          lat: geometry?.viewport?.southwest.lat ?? -180,
          lng: geometry?.viewport?.southwest.lng ?? -180,
        ),
      ),
      websiteUri: websiteUri,
      utcOffsetMinutes: utcOffsetMinutes,
      userRatingsTotal: userRatingsTotal,
    );
  }

  intern.OpeningHours _parseOpeningHours() {
    return intern.OpeningHours(
      periods: openingHours?.periods.map((e) {
            final openHour = int.parse(e.open.time.substring(0, 2));
            final openMinutes =
                int.parse(e.open.time.substring(2, e.open.time.length));
            intern.TimeOfWeek? close;
            if (e.close != null) {
              final closeTimes =
                  e.close!.time.split(':').map((e) => int.parse(e)).toList();

              close = intern.TimeOfWeek(
                day: intern.DayOfWeek.values[e.close?.day ?? 0],
                time: intern.PlaceLocalTime(
                  hours: closeTimes[0],
                  minutes: closeTimes[1],
                ),
              );
            }
            return intern.Period(
              open: intern.TimeOfWeek(
                day: intern.DayOfWeek.values[e.open.day],
                time: intern.PlaceLocalTime(
                  hours: openHour,
                  minutes: openMinutes,
                ),
              ),
              close: close,
            );
          }).toList() ??
          [],
      weekdayText: openingHours?.weekdayText ?? [],
    );
  }

  /// Parse an [Place] from json.
  factory Place.fromJson(Map<String, Object?> json) => _$PlaceFromJson(json);
}
