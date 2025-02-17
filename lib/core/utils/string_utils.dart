extension StringUtils on String? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }

  bool get isNotNullOrEmpty {
    return !isNullOrEmpty;
  }

  bool get isUrl {
    if (this.isNullOrEmpty) {
      return false;
    }

    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = new RegExp(pattern);

    return regExp.hasMatch(this!);
  }

  bool get isSystemPath {
    return this?.startsWith('i_protect/') ?? false;
  }
}
