/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Public attribution and hotlink metadata for one My Day background.
abstract class BackgroundPhoto implements _i1.SerializableModel {
  BackgroundPhoto._({
    required this.id,
    required this.imageUrl,
    required this.photographer,
    required this.photographerUrl,
    required this.photoUrl,
    bool? fromCache,
    String? source,
  }) : fromCache = fromCache ?? false,
       source = source ?? 'editorial';

  factory BackgroundPhoto({
    required String id,
    required String imageUrl,
    required String photographer,
    required String photographerUrl,
    required String photoUrl,
    bool? fromCache,
    String? source,
  }) = _BackgroundPhotoImpl;

  factory BackgroundPhoto.fromJson(Map<String, dynamic> jsonSerialization) {
    return BackgroundPhoto(
      id: jsonSerialization['id'] as String,
      imageUrl: jsonSerialization['imageUrl'] as String,
      photographer: jsonSerialization['photographer'] as String,
      photographerUrl: jsonSerialization['photographerUrl'] as String,
      photoUrl: jsonSerialization['photoUrl'] as String,
      fromCache: jsonSerialization['fromCache'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['fromCache']),
      source: jsonSerialization['source'] as String?,
    );
  }

  String id;

  String imageUrl;

  String photographer;

  String photographerUrl;

  String photoUrl;

  bool fromCache;

  String source;

  /// Returns a shallow copy of this [BackgroundPhoto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BackgroundPhoto copyWith({
    String? id,
    String? imageUrl,
    String? photographer,
    String? photographerUrl,
    String? photoUrl,
    bool? fromCache,
    String? source,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BackgroundPhoto',
      'id': id,
      'imageUrl': imageUrl,
      'photographer': photographer,
      'photographerUrl': photographerUrl,
      'photoUrl': photoUrl,
      'fromCache': fromCache,
      'source': source,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _BackgroundPhotoImpl extends BackgroundPhoto {
  _BackgroundPhotoImpl({
    required String id,
    required String imageUrl,
    required String photographer,
    required String photographerUrl,
    required String photoUrl,
    bool? fromCache,
    String? source,
  }) : super._(
         id: id,
         imageUrl: imageUrl,
         photographer: photographer,
         photographerUrl: photographerUrl,
         photoUrl: photoUrl,
         fromCache: fromCache,
         source: source,
       );

  /// Returns a shallow copy of this [BackgroundPhoto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BackgroundPhoto copyWith({
    String? id,
    String? imageUrl,
    String? photographer,
    String? photographerUrl,
    String? photoUrl,
    bool? fromCache,
    String? source,
  }) {
    return BackgroundPhoto(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      photographer: photographer ?? this.photographer,
      photographerUrl: photographerUrl ?? this.photographerUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      fromCache: fromCache ?? this.fromCache,
      source: source ?? this.source,
    );
  }
}
