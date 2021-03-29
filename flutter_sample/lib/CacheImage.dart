import 'dart:io';
import 'package:flutter_sample/Log.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TestImage {

  final String prefix;

  TestImage(this.prefix, {int maxSize}) : this.maxSize = maxSize ?? 1024 * 1024 * 1024;



  final int maxSize;
  int _totalSize = 0;
  int get totakSize => _totalSize;
  Map<String, FileSystemEntity> _map = {};
  Map<String, DateTime> _history = {};

  void init() async {


    _totalSize = 0;
    _map.clear();
    _history.clear();

    try {
      final Directory dir = await getTemporaryDirectory();

      Directory root = Directory('${dir.path}/$prefix');

      if(await root.exists() == false) {
        root = await root.create();
      }

      if(await root?.exists() == true) {
        List<FileSystemEntity> files = root.listSync();

        debug('cache count ${files.length}');

        Iterable<FileSystemEntity> it = files.where((element) => element.path.endsWith('.cache'));

        it.forEach((element) {
          final String path = element.path;

          if(path.endsWith('.cache')) {
            int index = path.lastIndexOf('/');

            if(index != -1) {
              final String key = path.substring(index + 1).replaceAll('.cache', '');

              FileStat stat = element.statSync();

              _totalSize += stat.size;
              _map.putIfAbsent(key, () => element);
            }
          }
        });
      }



    } catch(e) {
      error(e.toString());
    }
  }

  bool container(String key) {
    return _map.containsKey(key);
  }

  FileSystemEntity get(final String key) {
    return _map[key];
  }

  Future<File> put(String key, Uri uri) async {
    if(_map.containsKey(uri)) {
      debug('already exist $key');
      if(_history.containsKey(key))
        _history.update(key, (value) => DateTime.now());
      else
        _history.putIfAbsent(key, () => DateTime.now());
      return _map[key];
    }

    final Directory dir = await getTemporaryDirectory();

    Directory root = Directory('${dir.path}/$prefix');

    if(await root.exists() == false) {
      root = await root.create();
    }

    if(await root?.exists()) {
      final String name = '${root.path}/$key.cache';

      File file = File(name);

      if(await file.exists() != true) {

        debug('create $key');
        http.Response response = await http.get(uri.toString());

        if(response.statusCode == 200) {
          final int size = response.bodyBytes.length;

          if(_totalSize + size > maxSize) {

            var list = _map.entries.toList();

            int removeCount = 0;
            for(int i=0;  removeCount<list.length/3 &&  i<list.length; i++) {
              if(!_history.containsKey(list[i].key))  {
                removeCount++;
                await list[i].value.delete();
                _map.remove(key);
              }
            }


            


            int count = 0;
            _map.forEach((key, value) async {

            });

          }

          debug('body size ${response.bodyBytes.lengthInBytes} ${response.bodyBytes.length}');

          await file.writeAsBytes(response.bodyBytes, flush: true);


          debug('file size ${await file.length()} ');

          _totalSize += await file.length();



          _history.putIfAbsent(key, () => DateTime.now());

          _map.putIfAbsent(key, () => file);
        }
      } else {
        debug('already exist $key');
      }

      return file;
    }

    return null;
  }
}

class CacheImage {

  final String url;

  Map<String, String> map = {};

  CacheImage(this.url);

  void init() async {
    final Directory dir = await getTemporaryDirectory();

    List<FileSystemEntity> files = dir.listSync();

    int totalSize = 0;

    var it = files.iterator;

    while(it.moveNext()) {
      FileSystemEntity file = it.current;

      files.remove(it);
    }

    files = dir.listSync();

    for(var file in files) {
      FileStat stat = file.statSync();

      if(stat.accessed.isAfter( DateTime.now().add(Duration(minutes: 5)))) {

      }



      totalSize = stat.size;
    }
  }

  Future<bool> removeCacheImage(String key) async {

    File file = File(key);

    if(await file.exists()) {
      file.delete();
    }
  }

  Future<File> getImage() async {
    if(map.containsKey(url)) {

    }

    Directory dir = await getTemporaryDirectory();

    http.Response response = await http.get(url);

    switch(response.statusCode) {
      case 200:
        String name = url.replaceAll('https://', '').replaceAll('/', '_');

        String s ='${dir.path}/$name.cache';

        File file = File(s);

        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      default:
        break;
    }


    return null;
    return null;
  }
}