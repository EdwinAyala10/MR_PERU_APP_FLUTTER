import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class _LogEntry {
  _LogEntry({
    required this.requestLines,
    required this.stopwatch,
  });

  final List<String> requestLines;
  final Stopwatch stopwatch;
  List<String>? responseLines;
  List<String>? errorLines;
  bool requestPrinted = false;
  bool responsePrinted = false;
}

class ApiInterceptor extends Interceptor {
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      noBoxingByDefault: true,
      excludeBox: {},
    ),
  );

  static int _requestCounter = 0;
  static int _nextFlushId = 1;
  static const _requestIdKey = '_apiInterceptorRequestId';
  static final Map<int, _LogEntry> _pendingLogs = {};

  String _formatBlock(String icon, List<String> lines) {
    final buffer = StringBuffer()
      ..writeln(
        '$icon ┌------------------------------------------------------------------------------',
      );
    for (final line in lines) {
      buffer.writeln('$icon | $line');
    }
    buffer.write(
      '$icon └------------------------------------------------------------------------------',
    );
    return buffer.toString();
  }

  void _logRequestBlock(List<String> lines) {
    _logger.i(_formatBlock('🔵', lines));
  }

  void _logResponseBlock(List<String> lines) {
    _logger.i(_formatBlock('✅', lines));
  }

  void _logErrorBlock(List<String> lines) {
    _logger.e(_formatBlock('❌', lines));
  }

  List<String> _buildRequestLines(int requestId, RequestOptions options) {
    return [
      'Request #$requestId: ${options.method} ${options.uri}',
      if (options.queryParameters.isNotEmpty)
        'Query: ${options.queryParameters}',
      'Headers:',
      ...options.headers.entries.map(
        (entry) => '\t${entry.key}: ${entry.value}',
      ),
      'Body: ${options.data}',
    ];
  }

  List<String> _buildResponseLines(
    int requestId,
    Response response,
    String duration,
  ) {
    return [
      'Response #$requestId [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri} ($duration)',
      'Headers:',
      ...response.headers.map.entries.map(
        (entry) => '\t${entry.key}: ${entry.value.join(',')}',
      ),
      'Body: ${response.data}',
    ];
  }

  List<String> _buildErrorLines(
    int requestId,
    DioException err,
    String duration,
  ) {
    return [
      'Error #$requestId Type: ${err.type} ($duration)',
      'Method: ${err.requestOptions.method}',
      'URL: ${err.requestOptions.uri}',
      'Status Code: ${err.response?.statusCode}',
      'Message: ${err.message}',
      if (err.response != null) 'Response Data: ${err.response?.data}',
    ];
  }

  void _tryFlushLogs() {
    while (true) {
      final current = _pendingLogs[_nextFlushId];
      if (current == null) {
        break;
      }

      if (!current.requestPrinted) {
        _logRequestBlock(current.requestLines);
        current.requestPrinted = true;
      }

      final hasResponse = current.responseLines != null;
      final hasError = current.errorLines != null;

      if (hasResponse && !current.responsePrinted) {
        _logResponseBlock(current.responseLines!);
        current.responsePrinted = true;
      } else if (hasError && !current.responsePrinted) {
        _logErrorBlock(current.errorLines!);
        current.responsePrinted = true;
      }

      if (current.requestPrinted && current.responsePrinted) {
        _pendingLogs.remove(_nextFlushId);
        _nextFlushId++;
        continue;
      }

      break;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = ++_requestCounter;
    options.extra[_requestIdKey] = requestId;

    _pendingLogs[requestId] = _LogEntry(
      requestLines: _buildRequestLines(requestId, options),
      stopwatch: Stopwatch()..start(),
    );

    _tryFlushLogs();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra[_requestIdKey];
    if (requestId is int) {
      final entry = _pendingLogs[requestId];
      if (entry != null) {
        entry.stopwatch.stop();
        final elapsed = entry.stopwatch.elapsedMilliseconds;
        final duration = elapsed > 0 ? '$elapsed ms' : 'n/a';

        entry.responseLines = _buildResponseLines(
          requestId,
          response,
          duration,
        );
        _tryFlushLogs();
      } else {
        _logResponseBlock([
          'Response #$requestId [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}',
          'Body: ${response.data}',
        ]);
      }
    } else {
      _logResponseBlock([
        'Response [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}',
        'Body: ${response.data}',
      ]);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra[_requestIdKey];
    if (requestId is int) {
      final entry = _pendingLogs.putIfAbsent(
        requestId,
        () => _LogEntry(
          requestLines: _buildRequestLines(requestId, err.requestOptions),
          stopwatch: Stopwatch(),
        ),
      );

      if (entry.requestLines.length <= 1) {
        entry.requestLines
          ..clear()
          ..addAll(_buildRequestLines(requestId, err.requestOptions));
      }

      if (entry.stopwatch.isRunning) {
        entry.stopwatch.stop();
      }

      final elapsed = entry.stopwatch.elapsedMilliseconds;
      final duration = elapsed > 0 ? '$elapsed ms' : 'n/a';

      entry.errorLines = _buildErrorLines(requestId, err, duration);

      _tryFlushLogs();
    } else {
      _logErrorBlock([
        'Error Type: ${err.type}',
        'Method: ${err.requestOptions.method}',
        'URL: ${err.requestOptions.uri}',
        'Status Code: ${err.response?.statusCode}',
        'Message: ${err.message}',
        if (err.response != null) 'Response Data: ${err.response?.data}',
      ]);
    }

    super.onError(err, handler);
  }
}
