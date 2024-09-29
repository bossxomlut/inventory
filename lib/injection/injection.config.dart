// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_bloc/flutter_bloc.dart' as _i331;
import 'package:get_it/get_it.dart' as _i174;
import 'package:i_protect/core/utils/dio_utils.dart' as _i539;
import 'package:i_protect/core/utils/env.dart' as _i348;
import 'package:i_protect/data/repositories/authentication_repository.dart'
    as _i747;
import 'package:i_protect/data/repositories/authentication_repository_impl.dart'
    as _i985;
import 'package:i_protect/data/source/authentication_source.dart' as _i267;
import 'package:i_protect/presentation/authentication/cubit/login_cubit.dart'
    as _i503;
import 'package:i_protect/presentation/utils/bloc_observer.dart' as _i396;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    gh.factory<_i361.Dio>(() => dioModule.dio);
    gh.singleton<_i348.EnvLoader>(() => _i348.EnvLoader());
    gh.factory<_i331.BlocObserver>(() => _i396.AppBlocObserver());
    gh.factory<_i267.AuthenticationSource>(
        () => _i267.AuthenticationSource(gh<_i361.Dio>()));
    gh.factory<_i747.AuthenticationRepository>(() =>
        _i985.AuthenticationRepositoryImpl(gh<_i267.AuthenticationSource>()));
    gh.singleton<_i539.IConfig>(() => _i539.AppConfig());
    gh.factory<_i503.LoginCubit>(
        () => _i503.LoginCubit(gh<_i747.AuthenticationRepository>()));
    return this;
  }
}

class _$DioModule extends _i539.DioModule {}
