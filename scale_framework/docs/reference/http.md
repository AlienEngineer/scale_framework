# HTTP

This page describes the HTTP-related framework surface.

## `HttpConfiguration`

| Member | Meaning |
| --- | --- |
| `addRequestInterceptors(List<HttpRequestInterceptor> interceptors)` | appends request interceptors to the current chain |

`ModuleSetup` automatically registers the framework HTTP module, including the default URI-arguments interceptor.

## `HttpRequestInterceptor`

```dart
abstract class HttpRequestInterceptor {
  HttpRequestContext intercept(HttpRequestContext request);
}
```

Interceptors receive `HttpRequestContext` and return the next request context.

## `HttpRequestContext`

| Field | Meaning |
| --- | --- |
| `uri` | current request URI |
| `headers` | current header map |
| `arguments` | optional arguments passed to request execution |

### `copyWith(...)`

`copyWith(...)` merges new headers and arguments into the existing context instead of discarding previous values.

## `HttpGlobalInterception`

| Member | Meaning |
| --- | --- |
| `set(String key, String value)` | adds or overrides a header value |
| `resolveRequirement(String requirement, String value)` | fills a value only for a requirement that was previously declared |
| `getProvidedHeaders()` | returns keys currently available for request headers |

## `HttpHeadersFactory`

| Member | Meaning |
| --- | --- |
| `make()` | returns the final headers for a request |
| `pushNeeds(List<String> needs)` | marks required header names |

If unresolved requirements remain when `make()` runs, the framework throws `MissingRequirementsError`.

## `HttpRequest<TResult>`

| Member | Meaning |
| --- | --- |
| `execute([Map<String, Object>? arguments])` | runs the request and returns mapped result |

## `HttpGetRequest<TResult>`

Runtime behavior:

1. creates initial `HttpRequestContext`
2. applies request interceptors
3. executes `client.get(...)`
4. maps the response body with `MapperOf<TResult>`

Status-code mapping:

| Status | Result |
| --- | --- |
| `400` | `BadRequestException` |
| `404` | `ResourceNotFoundException` |
| `>= 500` | `ServerException` |

## URI placeholder replacement

The default HTTP module adds `ArgumentsHttpRequestInterceptor`, which replaces path segments like `{id}` using arguments passed to `execute(...)` or `context.refresh<T>(...)`.

## Interceptor failure behavior

If an interceptor throws, `HttpConfigurationInternal` catches the error, logs it only when debug printing is enabled, and continues processing with the current request context.

## Lower-level registration: `addHttpGetRequest<TDto>(...)`

Most feature code should use `addLoader<T, TDto>(...)`.

Use `addHttpGetRequest<TDto>(...)` directly only when you need request registration without loader state management.
