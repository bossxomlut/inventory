// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_bloc/flutter_bloc.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:sample_app/core/persistence/isar_storage.dart' as _i7;
import 'package:sample_app/core/persistence/local_key_value_storage.dart'
    as _i8;
import 'package:sample_app/core/persistence/security_storage.dart' as _i11;
import 'package:sample_app/core/persistence/simple_key_value_storage.dart'
    as _i12;
import 'package:sample_app/core/utils/app_remote_config.dart' as _i10;
import 'package:sample_app/data/repositories/authentication_repository.dart'
    as _i3;
import 'package:sample_app/data/repositories/authentication_repository_impl.dart'
    as _i4;
import 'package:sample_app/presentation/authentication/cubit/login_cubit.dart'
    as _i9;
import 'package:sample_app/presentation/utils/bloc_observer.dart' as _i6;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.AuthenticationRepository>(
        () => _i4.AuthenticationRepositoryImpl());
    gh.factory<_i5.BlocObserver>(() => _i6.AppBlocObserver());
    gh.singleton<_i7.IsarDatabase>(() => _i7.IsarDatabase());
    gh.singleton<_i8.LocalKeyValueStorage>(() => _i8.LocalKeyValueStorage());
    gh.factory<_i9.LoginCubit>(
        () => _i9.LoginCubit(gh<_i3.AuthenticationRepository>()));
    gh.singleton<_i10.RemoteAppConfigLoader>(
        () => _i10.RemoteAppConfigLoader());
    gh.singleton<_i10.RemoteAppConfigService>(
        () => _i10.RemoteAppConfigService());
    gh.singleton<_i11.SecurityStorage>(() => _i11.SecurityStorage());
    gh.singleton<_i12.SimpleStorage>(() => _i12.SimpleStorage());
    return this;
  }
}
