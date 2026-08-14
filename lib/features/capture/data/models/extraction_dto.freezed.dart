// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extraction_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExtractionDto {

@JsonKey(name: 'document_type') String get documentType; String get title; String get hospital; String get doctor;@JsonKey(name: 'document_date') String? get documentDate; List<FieldDto> get fields; List<MedicineDto> get medicines;@JsonKey(name: 'lab_values') List<LabValueDto> get labValues; List<String> get tags;@JsonKey(name: 'ocr_text') String get ocrText;
/// Create a copy of ExtractionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractionDtoCopyWith<ExtractionDto> get copyWith => _$ExtractionDtoCopyWithImpl<ExtractionDto>(this as ExtractionDto, _$identity);

  /// Serializes this ExtractionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractionDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.hospital, hospital) || other.hospital == hospital)&&(identical(other.doctor, doctor) || other.doctor == doctor)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&const DeepCollectionEquality().equals(other.fields, fields)&&const DeepCollectionEquality().equals(other.medicines, medicines)&&const DeepCollectionEquality().equals(other.labValues, labValues)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.ocrText, ocrText) || other.ocrText == ocrText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,title,hospital,doctor,documentDate,const DeepCollectionEquality().hash(fields),const DeepCollectionEquality().hash(medicines),const DeepCollectionEquality().hash(labValues),const DeepCollectionEquality().hash(tags),ocrText);

@override
String toString() {
  return 'ExtractionDto(documentType: $documentType, title: $title, hospital: $hospital, doctor: $doctor, documentDate: $documentDate, fields: $fields, medicines: $medicines, labValues: $labValues, tags: $tags, ocrText: $ocrText)';
}


}

/// @nodoc
abstract mixin class $ExtractionDtoCopyWith<$Res>  {
  factory $ExtractionDtoCopyWith(ExtractionDto value, $Res Function(ExtractionDto) _then) = _$ExtractionDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_type') String documentType, String title, String hospital, String doctor,@JsonKey(name: 'document_date') String? documentDate, List<FieldDto> fields, List<MedicineDto> medicines,@JsonKey(name: 'lab_values') List<LabValueDto> labValues, List<String> tags,@JsonKey(name: 'ocr_text') String ocrText
});




}
/// @nodoc
class _$ExtractionDtoCopyWithImpl<$Res>
    implements $ExtractionDtoCopyWith<$Res> {
  _$ExtractionDtoCopyWithImpl(this._self, this._then);

  final ExtractionDto _self;
  final $Res Function(ExtractionDto) _then;

/// Create a copy of ExtractionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? title = null,Object? hospital = null,Object? doctor = null,Object? documentDate = freezed,Object? fields = null,Object? medicines = null,Object? labValues = null,Object? tags = null,Object? ocrText = null,}) {
  return _then(_self.copyWith(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hospital: null == hospital ? _self.hospital : hospital // ignore: cast_nullable_to_non_nullable
as String,doctor: null == doctor ? _self.doctor : doctor // ignore: cast_nullable_to_non_nullable
as String,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String?,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldDto>,medicines: null == medicines ? _self.medicines : medicines // ignore: cast_nullable_to_non_nullable
as List<MedicineDto>,labValues: null == labValues ? _self.labValues : labValues // ignore: cast_nullable_to_non_nullable
as List<LabValueDto>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,ocrText: null == ocrText ? _self.ocrText : ocrText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractionDto].
extension ExtractionDtoPatterns on ExtractionDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractionDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractionDto value)  $default,){
final _that = this;
switch (_that) {
case _ExtractionDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractionDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractionDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_type')  String documentType,  String title,  String hospital,  String doctor, @JsonKey(name: 'document_date')  String? documentDate,  List<FieldDto> fields,  List<MedicineDto> medicines, @JsonKey(name: 'lab_values')  List<LabValueDto> labValues,  List<String> tags, @JsonKey(name: 'ocr_text')  String ocrText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractionDto() when $default != null:
return $default(_that.documentType,_that.title,_that.hospital,_that.doctor,_that.documentDate,_that.fields,_that.medicines,_that.labValues,_that.tags,_that.ocrText);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_type')  String documentType,  String title,  String hospital,  String doctor, @JsonKey(name: 'document_date')  String? documentDate,  List<FieldDto> fields,  List<MedicineDto> medicines, @JsonKey(name: 'lab_values')  List<LabValueDto> labValues,  List<String> tags, @JsonKey(name: 'ocr_text')  String ocrText)  $default,) {final _that = this;
switch (_that) {
case _ExtractionDto():
return $default(_that.documentType,_that.title,_that.hospital,_that.doctor,_that.documentDate,_that.fields,_that.medicines,_that.labValues,_that.tags,_that.ocrText);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_type')  String documentType,  String title,  String hospital,  String doctor, @JsonKey(name: 'document_date')  String? documentDate,  List<FieldDto> fields,  List<MedicineDto> medicines, @JsonKey(name: 'lab_values')  List<LabValueDto> labValues,  List<String> tags, @JsonKey(name: 'ocr_text')  String ocrText)?  $default,) {final _that = this;
switch (_that) {
case _ExtractionDto() when $default != null:
return $default(_that.documentType,_that.title,_that.hospital,_that.doctor,_that.documentDate,_that.fields,_that.medicines,_that.labValues,_that.tags,_that.ocrText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExtractionDto extends ExtractionDto {
  const _ExtractionDto({@JsonKey(name: 'document_type') this.documentType = 'scan', this.title = '', this.hospital = '', this.doctor = '', @JsonKey(name: 'document_date') this.documentDate, final  List<FieldDto> fields = const [], final  List<MedicineDto> medicines = const [], @JsonKey(name: 'lab_values') final  List<LabValueDto> labValues = const [], final  List<String> tags = const [], @JsonKey(name: 'ocr_text') this.ocrText = ''}): _fields = fields,_medicines = medicines,_labValues = labValues,_tags = tags,super._();
  factory _ExtractionDto.fromJson(Map<String, dynamic> json) => _$ExtractionDtoFromJson(json);

@override@JsonKey(name: 'document_type') final  String documentType;
@override@JsonKey() final  String title;
@override@JsonKey() final  String hospital;
@override@JsonKey() final  String doctor;
@override@JsonKey(name: 'document_date') final  String? documentDate;
 final  List<FieldDto> _fields;
@override@JsonKey() List<FieldDto> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

 final  List<MedicineDto> _medicines;
@override@JsonKey() List<MedicineDto> get medicines {
  if (_medicines is EqualUnmodifiableListView) return _medicines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medicines);
}

 final  List<LabValueDto> _labValues;
@override@JsonKey(name: 'lab_values') List<LabValueDto> get labValues {
  if (_labValues is EqualUnmodifiableListView) return _labValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labValues);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'ocr_text') final  String ocrText;

/// Create a copy of ExtractionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractionDtoCopyWith<_ExtractionDto> get copyWith => __$ExtractionDtoCopyWithImpl<_ExtractionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtractionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractionDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.hospital, hospital) || other.hospital == hospital)&&(identical(other.doctor, doctor) || other.doctor == doctor)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&const DeepCollectionEquality().equals(other._fields, _fields)&&const DeepCollectionEquality().equals(other._medicines, _medicines)&&const DeepCollectionEquality().equals(other._labValues, _labValues)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.ocrText, ocrText) || other.ocrText == ocrText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,title,hospital,doctor,documentDate,const DeepCollectionEquality().hash(_fields),const DeepCollectionEquality().hash(_medicines),const DeepCollectionEquality().hash(_labValues),const DeepCollectionEquality().hash(_tags),ocrText);

@override
String toString() {
  return 'ExtractionDto(documentType: $documentType, title: $title, hospital: $hospital, doctor: $doctor, documentDate: $documentDate, fields: $fields, medicines: $medicines, labValues: $labValues, tags: $tags, ocrText: $ocrText)';
}


}

/// @nodoc
abstract mixin class _$ExtractionDtoCopyWith<$Res> implements $ExtractionDtoCopyWith<$Res> {
  factory _$ExtractionDtoCopyWith(_ExtractionDto value, $Res Function(_ExtractionDto) _then) = __$ExtractionDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_type') String documentType, String title, String hospital, String doctor,@JsonKey(name: 'document_date') String? documentDate, List<FieldDto> fields, List<MedicineDto> medicines,@JsonKey(name: 'lab_values') List<LabValueDto> labValues, List<String> tags,@JsonKey(name: 'ocr_text') String ocrText
});




}
/// @nodoc
class __$ExtractionDtoCopyWithImpl<$Res>
    implements _$ExtractionDtoCopyWith<$Res> {
  __$ExtractionDtoCopyWithImpl(this._self, this._then);

  final _ExtractionDto _self;
  final $Res Function(_ExtractionDto) _then;

/// Create a copy of ExtractionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? title = null,Object? hospital = null,Object? doctor = null,Object? documentDate = freezed,Object? fields = null,Object? medicines = null,Object? labValues = null,Object? tags = null,Object? ocrText = null,}) {
  return _then(_ExtractionDto(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hospital: null == hospital ? _self.hospital : hospital // ignore: cast_nullable_to_non_nullable
as String,doctor: null == doctor ? _self.doctor : doctor // ignore: cast_nullable_to_non_nullable
as String,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String?,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldDto>,medicines: null == medicines ? _self._medicines : medicines // ignore: cast_nullable_to_non_nullable
as List<MedicineDto>,labValues: null == labValues ? _self._labValues : labValues // ignore: cast_nullable_to_non_nullable
as List<LabValueDto>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,ocrText: null == ocrText ? _self.ocrText : ocrText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FieldDto {

 String get key; String get label; String get value; double get confidence; String get note; List<String> get alternatives;
/// Create a copy of FieldDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldDtoCopyWith<FieldDto> get copyWith => _$FieldDtoCopyWithImpl<FieldDto>(this as FieldDto, _$identity);

  /// Serializes this FieldDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldDto&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.alternatives, alternatives));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,value,confidence,note,const DeepCollectionEquality().hash(alternatives));

@override
String toString() {
  return 'FieldDto(key: $key, label: $label, value: $value, confidence: $confidence, note: $note, alternatives: $alternatives)';
}


}

/// @nodoc
abstract mixin class $FieldDtoCopyWith<$Res>  {
  factory $FieldDtoCopyWith(FieldDto value, $Res Function(FieldDto) _then) = _$FieldDtoCopyWithImpl;
@useResult
$Res call({
 String key, String label, String value, double confidence, String note, List<String> alternatives
});




}
/// @nodoc
class _$FieldDtoCopyWithImpl<$Res>
    implements $FieldDtoCopyWith<$Res> {
  _$FieldDtoCopyWithImpl(this._self, this._then);

  final FieldDto _self;
  final $Res Function(FieldDto) _then;

/// Create a copy of FieldDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? value = null,Object? confidence = null,Object? note = null,Object? alternatives = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,alternatives: null == alternatives ? _self.alternatives : alternatives // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldDto].
extension FieldDtoPatterns on FieldDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldDto value)  $default,){
final _that = this;
switch (_that) {
case _FieldDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldDto value)?  $default,){
final _that = this;
switch (_that) {
case _FieldDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String value,  double confidence,  String note,  List<String> alternatives)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldDto() when $default != null:
return $default(_that.key,_that.label,_that.value,_that.confidence,_that.note,_that.alternatives);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String value,  double confidence,  String note,  List<String> alternatives)  $default,) {final _that = this;
switch (_that) {
case _FieldDto():
return $default(_that.key,_that.label,_that.value,_that.confidence,_that.note,_that.alternatives);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String value,  double confidence,  String note,  List<String> alternatives)?  $default,) {final _that = this;
switch (_that) {
case _FieldDto() when $default != null:
return $default(_that.key,_that.label,_that.value,_that.confidence,_that.note,_that.alternatives);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FieldDto extends FieldDto {
  const _FieldDto({this.key = '', this.label = '', this.value = '', this.confidence = 0.5, this.note = '', final  List<String> alternatives = const []}): _alternatives = alternatives,super._();
  factory _FieldDto.fromJson(Map<String, dynamic> json) => _$FieldDtoFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String label;
@override@JsonKey() final  String value;
@override@JsonKey() final  double confidence;
@override@JsonKey() final  String note;
 final  List<String> _alternatives;
@override@JsonKey() List<String> get alternatives {
  if (_alternatives is EqualUnmodifiableListView) return _alternatives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alternatives);
}


/// Create a copy of FieldDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldDtoCopyWith<_FieldDto> get copyWith => __$FieldDtoCopyWithImpl<_FieldDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FieldDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldDto&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._alternatives, _alternatives));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,value,confidence,note,const DeepCollectionEquality().hash(_alternatives));

@override
String toString() {
  return 'FieldDto(key: $key, label: $label, value: $value, confidence: $confidence, note: $note, alternatives: $alternatives)';
}


}

/// @nodoc
abstract mixin class _$FieldDtoCopyWith<$Res> implements $FieldDtoCopyWith<$Res> {
  factory _$FieldDtoCopyWith(_FieldDto value, $Res Function(_FieldDto) _then) = __$FieldDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String value, double confidence, String note, List<String> alternatives
});




}
/// @nodoc
class __$FieldDtoCopyWithImpl<$Res>
    implements _$FieldDtoCopyWith<$Res> {
  __$FieldDtoCopyWithImpl(this._self, this._then);

  final _FieldDto _self;
  final $Res Function(_FieldDto) _then;

/// Create a copy of FieldDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? value = null,Object? confidence = null,Object? note = null,Object? alternatives = null,}) {
  return _then(_FieldDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,alternatives: null == alternatives ? _self._alternatives : alternatives // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MedicineDto {

 String get name; String get dose; String get frequency; String get instruction;
/// Create a copy of MedicineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineDtoCopyWith<MedicineDto> get copyWith => _$MedicineDtoCopyWithImpl<MedicineDto>(this as MedicineDto, _$identity);

  /// Serializes this MedicineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineDto&&(identical(other.name, name) || other.name == name)&&(identical(other.dose, dose) || other.dose == dose)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.instruction, instruction) || other.instruction == instruction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,dose,frequency,instruction);

@override
String toString() {
  return 'MedicineDto(name: $name, dose: $dose, frequency: $frequency, instruction: $instruction)';
}


}

/// @nodoc
abstract mixin class $MedicineDtoCopyWith<$Res>  {
  factory $MedicineDtoCopyWith(MedicineDto value, $Res Function(MedicineDto) _then) = _$MedicineDtoCopyWithImpl;
@useResult
$Res call({
 String name, String dose, String frequency, String instruction
});




}
/// @nodoc
class _$MedicineDtoCopyWithImpl<$Res>
    implements $MedicineDtoCopyWith<$Res> {
  _$MedicineDtoCopyWithImpl(this._self, this._then);

  final MedicineDto _self;
  final $Res Function(MedicineDto) _then;

/// Create a copy of MedicineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? dose = null,Object? frequency = null,Object? instruction = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dose: null == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineDto].
extension MedicineDtoPatterns on MedicineDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineDto value)  $default,){
final _that = this;
switch (_that) {
case _MedicineDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineDto value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String dose,  String frequency,  String instruction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineDto() when $default != null:
return $default(_that.name,_that.dose,_that.frequency,_that.instruction);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String dose,  String frequency,  String instruction)  $default,) {final _that = this;
switch (_that) {
case _MedicineDto():
return $default(_that.name,_that.dose,_that.frequency,_that.instruction);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String dose,  String frequency,  String instruction)?  $default,) {final _that = this;
switch (_that) {
case _MedicineDto() when $default != null:
return $default(_that.name,_that.dose,_that.frequency,_that.instruction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicineDto extends MedicineDto {
  const _MedicineDto({this.name = '', this.dose = '', this.frequency = '', this.instruction = ''}): super._();
  factory _MedicineDto.fromJson(Map<String, dynamic> json) => _$MedicineDtoFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String dose;
@override@JsonKey() final  String frequency;
@override@JsonKey() final  String instruction;

/// Create a copy of MedicineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineDtoCopyWith<_MedicineDto> get copyWith => __$MedicineDtoCopyWithImpl<_MedicineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineDto&&(identical(other.name, name) || other.name == name)&&(identical(other.dose, dose) || other.dose == dose)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.instruction, instruction) || other.instruction == instruction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,dose,frequency,instruction);

@override
String toString() {
  return 'MedicineDto(name: $name, dose: $dose, frequency: $frequency, instruction: $instruction)';
}


}

/// @nodoc
abstract mixin class _$MedicineDtoCopyWith<$Res> implements $MedicineDtoCopyWith<$Res> {
  factory _$MedicineDtoCopyWith(_MedicineDto value, $Res Function(_MedicineDto) _then) = __$MedicineDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String dose, String frequency, String instruction
});




}
/// @nodoc
class __$MedicineDtoCopyWithImpl<$Res>
    implements _$MedicineDtoCopyWith<$Res> {
  __$MedicineDtoCopyWithImpl(this._self, this._then);

  final _MedicineDto _self;
  final $Res Function(_MedicineDto) _then;

/// Create a copy of MedicineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? dose = null,Object? frequency = null,Object? instruction = null,}) {
  return _then(_MedicineDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dose: null == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LabValueDto {

@JsonKey(name: 'metric_code') String get metricCode; double? get value;
/// Create a copy of LabValueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabValueDtoCopyWith<LabValueDto> get copyWith => _$LabValueDtoCopyWithImpl<LabValueDto>(this as LabValueDto, _$identity);

  /// Serializes this LabValueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabValueDto&&(identical(other.metricCode, metricCode) || other.metricCode == metricCode)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricCode,value);

@override
String toString() {
  return 'LabValueDto(metricCode: $metricCode, value: $value)';
}


}

/// @nodoc
abstract mixin class $LabValueDtoCopyWith<$Res>  {
  factory $LabValueDtoCopyWith(LabValueDto value, $Res Function(LabValueDto) _then) = _$LabValueDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'metric_code') String metricCode, double? value
});




}
/// @nodoc
class _$LabValueDtoCopyWithImpl<$Res>
    implements $LabValueDtoCopyWith<$Res> {
  _$LabValueDtoCopyWithImpl(this._self, this._then);

  final LabValueDto _self;
  final $Res Function(LabValueDto) _then;

/// Create a copy of LabValueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metricCode = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
metricCode: null == metricCode ? _self.metricCode : metricCode // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [LabValueDto].
extension LabValueDtoPatterns on LabValueDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabValueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabValueDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabValueDto value)  $default,){
final _that = this;
switch (_that) {
case _LabValueDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabValueDto value)?  $default,){
final _that = this;
switch (_that) {
case _LabValueDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'metric_code')  String metricCode,  double? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabValueDto() when $default != null:
return $default(_that.metricCode,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'metric_code')  String metricCode,  double? value)  $default,) {final _that = this;
switch (_that) {
case _LabValueDto():
return $default(_that.metricCode,_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'metric_code')  String metricCode,  double? value)?  $default,) {final _that = this;
switch (_that) {
case _LabValueDto() when $default != null:
return $default(_that.metricCode,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabValueDto implements LabValueDto {
  const _LabValueDto({@JsonKey(name: 'metric_code') this.metricCode = '', this.value});
  factory _LabValueDto.fromJson(Map<String, dynamic> json) => _$LabValueDtoFromJson(json);

@override@JsonKey(name: 'metric_code') final  String metricCode;
@override final  double? value;

/// Create a copy of LabValueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabValueDtoCopyWith<_LabValueDto> get copyWith => __$LabValueDtoCopyWithImpl<_LabValueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabValueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabValueDto&&(identical(other.metricCode, metricCode) || other.metricCode == metricCode)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricCode,value);

@override
String toString() {
  return 'LabValueDto(metricCode: $metricCode, value: $value)';
}


}

/// @nodoc
abstract mixin class _$LabValueDtoCopyWith<$Res> implements $LabValueDtoCopyWith<$Res> {
  factory _$LabValueDtoCopyWith(_LabValueDto value, $Res Function(_LabValueDto) _then) = __$LabValueDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'metric_code') String metricCode, double? value
});




}
/// @nodoc
class __$LabValueDtoCopyWithImpl<$Res>
    implements _$LabValueDtoCopyWith<$Res> {
  __$LabValueDtoCopyWithImpl(this._self, this._then);

  final _LabValueDto _self;
  final $Res Function(_LabValueDto) _then;

/// Create a copy of LabValueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metricCode = null,Object? value = freezed,}) {
  return _then(_LabValueDto(
metricCode: null == metricCode ? _self.metricCode : metricCode // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
