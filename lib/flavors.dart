enum Flavor {
  dev,
  stg,
  prod,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'シンプル給料記録アプリ Debug';
      case Flavor.stg:
        return 'シンプル給料記録アプリ Staging';
      case Flavor.prod:
        return 'シンプル給料記録アプリ';
    }
  }

}
