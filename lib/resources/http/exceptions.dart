class HttpException extends Error {
  var _statusCode = 0;

  get statusCode => _statusCode;

  set statusCode(value) {
    _statusCode = value;
  }

  HttpException(this._statusCode);
}

class ResourceNotFoundException extends HttpException {
  ResourceNotFoundException(super.statusCode);
}

class ServerException extends HttpException {
  ServerException(super.statusCode);
}
