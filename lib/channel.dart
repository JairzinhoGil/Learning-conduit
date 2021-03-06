import 'dart:io';

import 'package:conduit/conduit.dart';

import 'controller/heroes_controller.dart';

class HeroesChannel extends ApplicationChannel {
  late ManagedContext context;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = HeroConfig(options!.configurationFilePath!);

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/heroes/[:id]').link(() => HeroesController(context));

    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });

    return router;
  }
}

class HeroConfig extends Configuration {
  HeroConfig(String path) : super.fromFile(File(path));

  late DatabaseConfiguration database;
}
