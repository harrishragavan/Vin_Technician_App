// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 AuthStatus get status; AuthCredentials? get credentials; Map<String, dynamic>? get bootstrapInfo; String? get errorMessage; String? get errorDetail;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.credentials, _this.credentials) || other.credentials == _this.credentials)&&const DeepCollectionEquality().equals(other.bootstrapInfo, _this.bootstrapInfo)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail));
}


@override
int get hashCode {
  final _this = this as AuthState;
  return Object.hash(runtimeType,_this.status,_this.credentials,const DeepCollectionEquality().hash(_this.bootstrapInfo),_this.errorMessage,_this.errorDetail);
}

@override
String toString() {
  final _this = this as AuthState;
  return 'AuthState(status: ${_this.status}, credentials: ${_this.credentials}, bootstrapInfo: ${_this.bootstrapInfo}, errorMessage: ${_this.errorMessage}, errorDetail: ${_this.errorDetail})';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 AuthStatus status, AuthCredentials? credentials, Map<String, dynamic>? bootstrapInfo, String? errorMessage, String? errorDetail
});




}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? credentials = freezed,Object? bootstrapInfo = freezed,Object? errorMessage = freezed,Object? errorDetail = freezed,}) {
  return _then(AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as AuthCredentials?,bootstrapInfo: freezed == bootstrapInfo ? _self.bootstrapInfo : bootstrapInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthStatus status,  AuthCredentials? credentials,  Map<String, dynamic>? bootstrapInfo,  String? errorMessage,  String? errorDetail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.credentials,_that.bootstrapInfo,_that.errorMessage,_that.errorDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthStatus status,  AuthCredentials? credentials,  Map<String, dynamic>? bootstrapInfo,  String? errorMessage,  String? errorDetail)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.status,_that.credentials,_that.bootstrapInfo,_that.errorMessage,_that.errorDetail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthStatus status,  AuthCredentials? credentials,  Map<String, dynamic>? bootstrapInfo,  String? errorMessage,  String? errorDetail)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.credentials,_that.bootstrapInfo,_that.errorMessage,_that.errorDetail);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState implements AuthState {
  const _AuthState({this.status = AuthStatus.loading, this.credentials,  Map<String, dynamic>? bootstrapInfo, this.errorMessage, this.errorDetail}): _bootstrapInfo = bootstrapInfo;
  

@override@JsonKey() final  AuthStatus status;
@override final  AuthCredentials? credentials;
 final  Map<String, dynamic>? _bootstrapInfo;
@override Map<String, dynamic>? get bootstrapInfo {
  final value = _bootstrapInfo;
  if (value == null) return null;
  if (_bootstrapInfo is EqualUnmodifiableMapView) return _bootstrapInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? errorMessage;
@override final  String? errorDetail;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.credentials, credentials) || other.credentials == credentials)&&const DeepCollectionEquality().equals(other.bootstrapInfo, _bootstrapInfo)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,credentials,const DeepCollectionEquality().hash(_bootstrapInfo),errorMessage,errorDetail);
}

@override
String toString() {
    return 'AuthState(status: $status, credentials: $credentials, bootstrapInfo: $bootstrapInfo, errorMessage: $errorMessage, errorDetail: $errorDetail)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 AuthStatus status, AuthCredentials? credentials, Map<String, dynamic>? bootstrapInfo, String? errorMessage, String? errorDetail
});




}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? credentials = freezed,Object? bootstrapInfo = freezed,Object? errorMessage = freezed,Object? errorDetail = freezed,}) {
  return _then(_AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as AuthCredentials?,bootstrapInfo: freezed == bootstrapInfo ? _self._bootstrapInfo : bootstrapInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
