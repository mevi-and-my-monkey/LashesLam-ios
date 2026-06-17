# LashesLam iOS

App iOS nativa (SwiftUI) de **LashesLam**, portada desde la app Android. Consume el **mismo backend
de Firebase** (`lasheslam-ed6cf`): Firestore, Auth, Storage, Remote Config — por lo que comparte
datos, usuarios y administradores con la app Android.

## Estado (Etapa 1)

Implementado: proyecto + Firebase (SPM), tema/colores, splash, **login/registro con email**,
**Google Sign-In**, gestión de sesión y detección de admin vía Remote Config. `HomeView` es un stub.

Pendiente (etapas siguientes): tienda + carrito, cursos + inscripciones, servicios + citas,
favoritos, perfil con foto y funciones de administrador.

## Arquitectura

MVVM + Clean, espejando la app Android:

```
LashesLam/
├── App/          LashesLamApp (entry), AppRootView (splash→login→home)
├── Core/         Theme (AppColors, Typography), Result (Resource), Error (AppError, ErrorMapper)
├── Data/         Constants (FirestorePaths, StoragePaths), Dto, Models, Repositories
├── Session/      SessionManager (estado global observable)
├── Features/     Splash, Auth (LoginViewModel + vistas), Home
└── Components/    PrimaryButton, OutlinedButton, WavyBackground
```

## Requisitos

- Xcode 16+ y un simulador iOS.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) para (re)generar el proyecto: `brew install xcodegen`.

## Configuración inicial (una vez)

1. **Registrar la app iOS en Firebase Console** del proyecto `lasheslam-ed6cf`:
   *Agregar app → iOS*, Bundle ID `com.mevi.lasheslam.ios`.
2. Descargar **`GoogleService-Info.plist`** y colocarlo en `LashesLam/GoogleService-Info.plist`.
3. En Authentication → Sign-in method, confirmar **Email/Password** y **Google** habilitados.
4. En `LashesLam/Info.plist`, reemplazar `REVERSED_CLIENT_ID_PLACEHOLDER` por el valor
   `REVERSED_CLIENT_ID` que viene dentro del `GoogleService-Info.plist` (URL Scheme para Google).

## Generar y compilar

```bash
xcodegen generate
open LashesLam.xcodeproj
# o por línea de comandos:
xcodebuild -project LashesLam.xcodeproj -scheme LashesLam \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

> El proyecto (`LashesLam.xcodeproj`) se genera desde `project.yml`. Si editas dependencias o
> estructura, vuelve a correr `xcodegen generate`.
