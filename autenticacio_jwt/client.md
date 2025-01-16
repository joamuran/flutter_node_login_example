# Configuració del client en Flutter


## Configuració d'HTTPS

Flutter gestiona automàticament la verificació de certificats quan treballem amb certificats emesos per autoritats reconegudes, garantint així connexions segures en entorns de producció.

Ara bé, quan treballem amb certificats autofirmats (com en entorns de desenvolupament), Flutter, de manera predeterminada, rebutja aquestes connexions, ja que no pot verificar la confiança del certificat.

Per solucionar-ho, Flutter ens permet substituir la validació predeterminada dels certificats mitjançant el paquet `dart:io`. Això ens permet personalitzar el client HTTP perquè accepte certificats autofirmats en escenaris controlats.

> ![NOTE] Sobre clients HTTP i la llibreria http
> 
> Fins ara, hem treballat amb la llibreria http per realitzar connexions HTTP. Aquesta llibreria proporciona una interfície d'alt nivell per enviar sol·licituds HTTP, però 
> 
> 
> Fins ara hem treballat amb [la llibreria `http`](https://pub.dev/packages/http) per realitzar connexions HTTP. Aquesta llibreria ens proporciona  una interfície d'alt nivell per enviar sol·licituds HTTP, però internament utilitza implementacions de més baix nivell, com [IOClient o BrowserClient](https://pub.dev/packages/http#choosing-an-implementation)), segons la plataforma.
> Això ens permet triar la implementació adequada en funció de les nostres necessitats.
> 

En lloc d'utilitzar el client http directament, en aquest cas haurem de crear un client HTTP personalitzat que ens permeta acceptar certificats autofirmats. Per aconseguir-ho, farem ús de la classe [`HttpClient`](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html), que ens proporciona un control de baix nivell sobre les connexions HTTP.

### La funció badCertificateCallback

La classe `HttpClient` inclou el mètode `badCertificateCallback`, que ens permet definir una funció de `callback` per determinar si acceptem o rebutgem un certificat no reconegut.

Quan es fa una sol·licitud HTTPS, si el servidor proporciona un certificat que no és de confiança, s'invoca aquest callback. La funció rep tres paràmetres:

* El *Certificat* (`X509Certificate`) proporcionat pel servidor,
* El nom de l'amfitrió (`host`), és a dir, el servidor al què ens connectem, i 
* El Port (*port*) que s'utilita per a la connexió.

Si el callback retorna:

* `true`: El certificat és acceptat i la connexió continua.
* `false` o `null`: El certificat és rebutjat i la connexió es tanca.
  
Veiem alguns detalls d'aquesta implementació:

```dart
// Importem la nostra llibreria per al client HTTP
import 'package:basic_auth_client/infrastructure/http_service.dart';

class AuthRemoteDataSource {
  // Instància del client HTTP personalitzat
  late final HttpService _httpService;

  // Constructor, que inicialitza HttpService
  // amb la url de base.
  AuthRemoteDataSource(String baseUrl) {
    _httpService = HttpService(baseUrl);
  }
  

  Future<bool> login(String username, String password) async {
    // Modifiquem les peticions http per tal d'utilitzar
    // el nostre servei.
    final response = await _httpService.post(
      '/auth/login',
      {"username": username, "password": password},
    );
    
    if (response.statusCode == 200) {
      // Obtenim el token de la resposta
      final data = jsonDecode(response.body);
      // Tenim el token en data['token`] (ja veurem què fem amb ell)
      return true; // Validem el login
    } else {
      throw Exception('Error d’autenticació');
    }
  }
}

```

Amb això, només haurem de modificar la funció main per connectar-nos per HTTPS:

```dart
  final authRemoteDatasource = AuthRemoteDataSource("https://10.0.2.2:3000");
  final authRepository = AuthRepositoryImpl(authRemoteDatasource);
  runApp(LoginApp(repository: authRepository));
```

> [!NOTE]
> **Configuració per a Android i IOS**
> 
> Es possible que el certificat autofirmat causa problemes a Android o iOS. Si aquest és el cas, podem permetre connexions no segures en el fitxer `android/app/src/main/res/xml/network_security_config.xml`, amb el següent contingut:
>
> ```xml
> <?xml version="1.0" encoding="utf-8"?>
> <network-security-config>
>    <domain-config cleartextTrafficPermitted="true">
>        <domain includeSubdomains="true">10.0.2.2</domain>
>    </domain-config>
> </network-security-config>
> ```
>
> I afegitm aquest aconfiguració al fitxer `AndroidManifest.xml`:
>
> ```xml
>
> <application
>    android:networkSecurityConfig="@xml/network_security_config"
>    ...>
>
> Per a iOS, si necessitem acceptar certificats autofirmats, editarem el fitxer `ios/Runner/Info.plist` i afegirem:
>
> ```xml
> <key>NSAppTransportSecurity</key>
> <dict>
>    <key>NSAllowsArbitraryLoads</key>
>    <true/>
> </dict>
>

## Guardant el token a SharedPreferences

Una vegada tenim el token, l'hem d'emmagatzemar en algun lloc per enviar-lo en posteriors peticions.

Una forma denzilla de fer-ho és mitjançant [la llibreria `shared_preferences`](https://pub.dev/packages/shared_preferences), que proporciona emmagatzemament persistent al dispositiu per a dades simples, en format *clau-valor*.

El primer que farem serà doncs instal·lar la llibreria:

```bash
flutter pub add shared_preferences
```

Aquesta llibreria requereix d'una versió igual o superior a la versió 8.2.1 del plugin d'aplicació d'Android, així que haurem d'afegir una modificació al projecte. Editarem el fitxer `android/settings.gradle` i modificarem la línia:

```groovy
id "com.android.application" version "8.1.0" apply false
```

per:

```groovy
id "com.android.application" version "8.2.1" apply false
```

Ara ja podem fer ús d'ella al fitxer `http_service.dart`. El primer que fem és importar-la:

```dart
import 'package:shared_preferences/shared_preferences.dart';
```

I quan validem l'usuari i el servidor ens retorne el token, el guardem en SharedPreferences. Per a això, modificarem el mètode de login amb:

```dart
Future<bool> login(String username, String password) async {
    final response = await _httpService.post(
      '/auth/login',
      {"username": username, "password": password},
    );

    if (response.statusCode == 200) 
      final data = jsonDecode(response.body);

      // NOU:Guardem el token a SharedPreferences

      // 1. Obtenim una instància de sharesPreferences
      final prefs = await SharedPreferences.getInstance();
      // 2. Guardem el token amb la clau jwt
      await prefs.setString('jwt', data['token']);

      // I validem l'autenticació
      return true;
    } else {
      throw Exception('Error d’autenticació');
    }
  }
```

Amb això tindrem l'usuari validat, i a més, el token disponible per a quan el necessitem.


### Com realitzar peticions amb el token?

Per incloure el token a les nostres peticipns anem a implementar un mpetode específic.

Però abans, com que hem d'incorporar el token a capçalera de la petició, hem de modifica el mètode get del nostre client HTTP, per a que accepte un paràmetre més, consistent en un diccionari.

El mètode `get` que teniem fins ara rebia només un `String`, amb l'endpoint:

```dart
Future<http.Response> get(String endpoint) async {...}
```

Ara el que farem és el següent:

```dart
Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final ioClient =
        IOClient(createHttpClient()); // Usa el client personalitzat
    final url = Uri.parse('$baseUrl$endpoint');

    return ioClient.get(url, headers: headers);
  }
```

Com veiem, rebem un no paràmetre de tipus Map anomenat `headers`, que el proporcionarem al client HTTP ioClient.

Ara ja podem crear un nou mètode a `AuthRemoteDatasource` per accedir a recursos protegits, incorporant el token a l'autorització:

```dart
Future<http.Response> getProtectedResource(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) throw Exception("L'usuari no està autenticat");

    return _httpService.get(endpoint, headers: {
      "Authorization": "Bearer $token",
    });
  }
```

Com veiem, és molt semblant a una petició GET, amb la diferència que afegim el camp `headers` amb `Authorization` Amb el prefic *Bearer* en `Bearer $token`informem explícitament al servidor que la capçalera conté un token que cal validar com a part de l'autenticació.

## Pantalla inicial

Amb aquests canvis, modificat la pantalla principal per a que permeta l'accés a un recurs protegit.
