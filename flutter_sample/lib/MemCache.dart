import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'Log.dart';

class CacheObject<T> {
  DateTime access;
  final T _data;

  T get data {
    access = DateTime.now();
    return _data;
  }

  CacheObject(T data) :
        _data = data,
        access = DateTime.now();
}

class MemCache {
  static MemCache _instance;

  MemCache._internal() {
    _instance = this;
  }

  static MemCache get instance => _instance ?? MemCache._internal();

  final String name = 'imageCache';

  final int maxSize= 1024 * 1024 * 200;
  int _totalSize = 0;
  int get totalSize => _totalSize;
  Map<String, CacheObject<File>> _map2 = {};
  Map<String, DateTime> _history = {};
  Map<String, CacheObject<Uint8List>> _memCache2 = {};
  Map<String, Completer<Uint8List>> _completer = {};

  final int memCacheMaxSize = 1024 * 1024 * 50;
  int _memCacheSize = 0;

  void removeOldCache() async {
    final Directory dir = await getRootDir();

    List<FileSystemEntity> files = dir.listSync();

    for(var f in files) {
      FileStat stat = await f.stat();

      if(stat.accessed.isBefore(DateTime.now().subtract(Duration(days: 7))))
        await f.delete();

    }

    init();
  }


  void init() async {
    _totalSize = 0;
    _map2.clear();
    _memCache2.clear();
    _completer.clear();

    try {
      final Directory dir = await getTemporaryDirectory();

      Directory root = await getRootDir();

      if(await root?.exists() == true) {
        List<FileSystemEntity> files = root.listSync();

        debug('cache image count ${files.length}');

        Iterable<FileSystemEntity> it = files;

        it.forEach((element) async {
          final String path = element.path;

          int index = path.lastIndexOf('/');

          if(index != -1) {
            final String key = path.substring(index + 1);

            FileStat stat = element.statSync();

            _totalSize += stat.size;
            _map2.putIfAbsent(key, () => CacheObject(element));
          }
        });
      }



    } catch(e) {
      error(e.toString());
    }

    debug('cache map count ${_map2.length}');

    return;
  }

  Future<Directory> getRootDir() async {
    final Directory dir = await getTemporaryDirectory();

    Directory root = Directory('${dir.path}/$name');

    if(await root.exists() == false) {
      root = await root.create();
    }

    return root;
  }

  void recycle() async {
    debug('recycle');
    var list = _map2.entries.toList();

    final Directory root = await getRootDir();

    final FileStat stat = await root.stat();

    {
      var files = root.listSync();

      int size = 0;

      for(var v in files) {
        size = v.statSync().size;
      }

      debug('before count:${files.length} size:$size');
    }

    final int removeCount = list.length~/3;
    int count = 0;
    for(int i=0;  count<removeCount &&  i<list.length; i++) {
      if(!_history.containsKey(list[i].key))  {
        _map2.remove(list[i].key);
        count++;
        File file = list[i].value.data;
        _totalSize -= await file.length();
        await file.delete();
      }
    }

    var it = _map2.entries.iterator;

    while(count++ < removeCount && it.moveNext()) {
      final String key = it.current.key;
      File file = it.current.value.data;

      await file.delete();
    }


    {
      var files = root.listSync();

      int size = 0;

      for(var v in files) {
        size = v.statSync().size;
      }

      debug('after count:${files.length} size:$size');
    }

    init();
  }

  void clear() async {
    final Directory = await getRootDir();

    List<FileSystemEntity> files = Directory.listSync();

    for(var f in files) {
      f.deleteSync();
    }

    if(_completer.isNotEmpty == true) {
      for(var completer in _completer.values) {
        if(!completer.isCompleted)
          await completer.future;
      }
    }

    _completer.clear();
    _memCache2.clear();
    _map2.clear();
    _history.clear();
    _totalSize = 0;
    _memCacheSize = 0;

    init();
  }


  Stream get_Stream(String value) async* {

  }

  Future<Uint8List> getData(String path) async {
    File file = File(path);

    return await file.readAsBytes();
  }
  
  Stream testAsync(String key, String path) async* {

    yield await saveCache( SaveParam(path, name));
  }

  Stream addCache(String key, String uri) async* {
    debug('addCache $key $uri');

    Completer completer = _completer[key];

    try {
      http.Response response = await http.get(uri);

      if(response.statusCode == 200) {
        completer?.complete(response.bodyBytes);

        final Directory root = await getRootDir();
        final String name = '${root.path}/$key';

        File file = File(name);
        file.writeAsBytesSync(response.bodyBytes, flush: true);

        _memCache2.putIfAbsent(key, () => CacheObject(response.bodyBytes));
        _map2.putIfAbsent(key, () => CacheObject(file));

        yield response.bodyBytes;
      }
    } catch(e) {
      error(e.toString());
    }

    yield null;
  }


  Future<Uint8List> addCache2(String key, String uri) async {
    debug('addCache $key $uri');

    Completer completer = _completer[key];

    try {
      http.Response response = await http.get(uri);

      if(response.statusCode == 200) {
        completer?.complete(response.bodyBytes);

        final Directory root = await getRootDir();
        final String name = '${root.path}/$key';

        File file = File(name);
        file.writeAsBytes(response.bodyBytes, flush: true).whenComplete(() {
          debug('add Cache');
          _memCache2.putIfAbsent(key, () => CacheObject(response.bodyBytes));
          _map2.putIfAbsent(key, () => CacheObject(file));
        });

        return response.bodyBytes;

      }
    } catch(e) {
      error(e.toString());
    }

    return null;
  }

  Future<ImageProvider> get(String value) async {
    debug('get s');

    final Uri uri = Uri.tryParse(value);

    if(uri == null)
      return null;

    final String key = uri.path.replaceAll('/', '_').replaceAll('.', '__');


    if(_memCache2.containsKey(key)) {
      debug('get mem cache');
      return MemoryImage(_memCache2[key].data);
    }

    if(_map2.containsKey(key)) {
      debug('get file cache');
      File file = _map2[key].data;

      debug('file read s');
      Uint8List data = await compute(getData, file.path);
      debug('file read e');

      if(!_memCache2.containsKey(key))
        _memCache2.putIfAbsent(key, () => CacheObject(data));

      return MemoryImage(data);
    }

    if(_completer.containsKey(key)) {
      debug('cache waiting..');
      Completer<Uint8List> completer = _completer[key];
      Uint8List data = await completer.future;

      _completer.remove(key);

      debug('cache get..');
      return MemoryImage(data);
    }



    debug('save call s $name');

    final Completer<Uint8List> completer = Completer<Uint8List>();

    _completer.putIfAbsent(key, () => completer);
    Uint8List data = await addCache2(key, uri.toString());
   // var r = addCache(key, uri.toString());
    return MemoryImage(data);
  }
}

class SaveParam {
  final String uri;
  final String path;

  SaveParam(this.uri, this.path);
}

Future<Uint8List> saveCache(SaveParam param) async {
  debug('save s ${param.path}');
  final uri = param.uri;
  final filePath = param.path;

  try {
    File file = File(filePath);

    if(!file.existsSync()) {
      http.Response response = await http.get(uri);

      if(response.statusCode == 200) {
        file.writeAsBytesSync(response.bodyBytes, flush: true);
        return response.bodyBytes;
      } else {

      }
    } else {
      debug('already exist');
      return file.readAsBytesSync();
    }
  } catch(e) {
    error(e.toString());
  }

  return null;
}