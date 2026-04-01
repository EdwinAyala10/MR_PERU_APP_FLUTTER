
# Please use the same version of Gradle (Java JDK, Kotlin) and Flutter as the project.

## Gradle

```
------------------------------------------------------------
Gradle 8.12
------------------------------------------------------------

Build time:    2024-12-20 15:46:53 UTC
Revision:      a3cacb207fec727859be9354c1937da2e59004c1

Kotlin:        2.0.21
Groovy:        3.0.22
Ant:           Apache Ant(TM) version 1.10.15 compiled on August 25 2024
Launcher JVM:  21.0.10 (Microsoft 21.0.10+7-LTS)
Daemon JVM:    /Users/chapitec/Library/Java/JavaVirtualMachines/ms-21.0.10/Contents/Home (from org.gradle.java.home)
OS:            Mac OS X 26.2 aarch64

```

## Flutter

```
Flutter 3.38.9 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 67323de285 (10 days ago) • 2026-01-28 13:43:12
-0800
Engine • hash 5eb06b7ad5bb8cbc22c5230264c7a00ceac7674b (revision
587c18f873) (10 days ago) • 2026-01-27 23:23:03.000Z
Tools • Dart 3.10.8 • DevTools 2.51.1

Para cambiar el nombre de la aplicación
````
flutter pub run change_app_package_name:main com.mr_peru.crm_app
````

Para cambiar el icono de la aplicación
````
flutter pub run flutter_laucher_icons
````

Para cambiar el splash screen
````
flutter pub run flutter_native_splash:create
````



edwin.rccperu@gmail.com
74047949

richard.ramirez@mrperu.com.pe
43502560


Gorouter:
Pista : Analizar como trabajan las navegaciones por path en un navegador web ya que 
go router trabaja de esa manera




.push('/company_check_in/$ids')

Pushea hacia esa ruta concatenando el valor ids.
El problema ocurre porque ids contiene texto largo con caracteres especiales, y si dentro viene un / el router lo interpreta como si fuera otro segmento de ruta y termina cortando el valor, provocando que no llegue completo y falle la navegación

Ejemplo donde falla porque contiene s/n (tiene /) que es el caso donde se reprodujo el error
01*20104582428*2*PLANTA LURÍN Cayma s/n, Lurín 15823, Peru*-12.2963481*-76.8373387

Ejemplo donde tampoco esta funcionando porque no contiene pero lo esta leyendo de la siguiente forma, el aplicativo en esta parte:

01*20100019516*2*PLANTA CALLAO Av. Bocanegra 135, Callao 07031, Peru*-12.0115429*-77.11019329999999


GoException: no routes for location: /company_check_in/
01*20100019516*2*PLANTA%20CALLAO%20Av.%20Bocanegra%20 /%20135,%20Callao%2007031,%20Peru*-12.0115429*-77.11019329 999999