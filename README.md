# UPM: Práctica Clarive de ciclo de vida de aplicación J2EE

## Descripción de la práctica

El objetivo de la práctica es que el alumno se familiarice con un proceso de desarrollo
similar a los que encontrará en cualquier organización para el despliegue de aplicaciones
en distintos entornos (integración, test, producción, etc.). El administrador ha definido
un ciclo de vida y una serie de *quality gates* (modelo de calidad) que la aplicación
objetivo tendrá que cumplir para poder ser desplegada en el entorno de Producción
satisfactoriamente.

## Cambios en la aplicación

Cada cambio que se vaya a realizar en la aplicación debe estar registrado en Clarive
como un __tópico__ de tipo __changeset__. Las categorías definidas en el entorno implementado
para esta práctica son __Feature__, __Story__, __BugFix__ y __HotFix__. Estos cambios se pueden
organizar para el control del desarrollo agrupados en __Epics__ y a su vez en __Sprints__.

Cada uno de estos tópicos de tipo _changeset_ tendrá toda la información asociada
al cambio: descripción del cambio funcional, documentación asociada, rama de desarrollo
en el repositorio git, etc.

Además, el tópico nos permitirá realizar el despliegue en
los distintos entornos (INTE, TEST y PROD) de manera automatizada y nos guiará a
través del ciclo de vida.

## Ciclo de vida

Los tópicos se crearán siempre en un estado pendiente llamado __To Do__.
Cuando se vaya a empezar el desarrollo o cambio, el tópico se transitará
a __In Progress__. En ese momento Clarive automatiza la creación de una
rama asociada a ese tópico en el repositorio (a partir de la rama master)
para controlar los cambios de código relacionados con ese tópico (ej. si el
tópico es una feature, se creará la rama feature/<ID-nombre-de-la-feature>). 

Cada vez que se hace un __push__ al repositorio en esa rama (es decir, se envían
los cambios realizados en la rama al servidor de repositorios), Clarive lanza
de manera automática un __job__ de despliegue al entorno de integración.

Una vez que se da por válido el desarrollo o cambio realizado (el job ha finalizado
con éxito y la pruebas funcionales básicas del desarrollador en el entorno de integración
son satisfactorias), el tópico se deberá transitar a __In Review__. Si se ha seleccionado algún
__reviewer__ para el tópico este recibirá un correo avisando de que ese cambio está
disponible para ser probado en el entorno de integración.


El __reviewer__ podrá aprobar el cambio y transitarlo a __Ready__ o rechazarlo
y devolverlo a __In Progress__.  Un cambio sólo se podrá pasar a __Ready__
si está asociado a una __Release__.  En el momento de transitar el cambio
a __Ready__, Clarive automaticamente hará lo siguiente:

1. Crear la rama de release si no existe (a partir de la rama master. ej. release/relase-7.3)
2. Integrar los cambios de la rama asociada al cambio en la rama de release. (ej. merge de
la rama feature/ID-nombre-de-la-feature con la rama release/release-7.3)
Si existen conflictos al realizar la integración, se notificará al usuario
que deberá resolverlos en la rama de __Release__ y volver a realizar la transición
del cambio.
3. Cuando el último cambio de la __Release__ pasa al estado __Ready__ la __Release__
se transita automáticamente a __In Review__.

En ese momento el _reviewer_ puede revisar la calidad de la aplicación en el
entorno de _test_ desplegando desde el tópico __Release__ todos los cambios
contenidos a la vez.

Una vez que la __Release__ haya sido aprobada se transitará manualmente por
el _reviewer_ a __Ready__, momento en el que todos los cambios contenidos
transitarán de manera automática a __Frozen__.  Clarive bloqueará el push a
las ramas de cambio en cualquier estado distinto a __In Progress__ o __In
Review__.

La __Release__ se podrá desplegar manualmente al entorno de _producción_ y
si el despliegue es satisfactorio todos los cambios y la release pasarán
automáticamente a __Done__.  Además Clarive automatiza la integración de
la rama de __Release__ en _master_, el borrado de las ramas de desarrollo
y de release y la creación de tags de versión en el repositorio de código.

## Fichero .clarive.yml

El Fichero .clarive.yml en el / del repositorio es donde se encuentra
la lógica de construcción y testing de la aplicación.

En el repositorio de ejemplo encontrarás el siguiente contenido en el
fichero .clarive.yml:

```yaml
build:
  do:
    - shell [Building application]:
        cmd: cd ${project}/${repository} && mvn package
        image: maven
test:
  do:
    - shell [Executing unit tests]:
        cmd: cd ${project}/${repository} && mvn test
        image: maven
post:
  - email:
      body: xxxxxxxxxxxxxxxxxxxx
      subject: Project ${project}/${repository} deployed to ${environment}
      to:
        - ${job_user}
```

En este caso la aplicación contenida en el repositorio debe poder ser
construida con maven (deberá haber un fichero pom.xml en el / del repositorio).

Los comandos a ejecutar para los pasos build y test se ejecutarán siempre en
un contenedor Docker que se arrancará a partir de la imagen especificada en el
parámetro `image` de la operación `shell`.  Se puede utilizar cualquier imagen
disponible en [DockerHub](https://hub.docker.com).  Si no está disponible 
localmente se descargará en la primera ejecución de un pipeline que la utilice
y estará disponible para subsiguientes ejecuciones.

## Pipeline

El despliegue automatizado en el entorno Clarive de la práctica se realiza
mediante una regla de pipeline con las siguientes características:

1. Stages:

Todo despliegue se ejecuta en 5 pasos:

  * *CHECK*: Se ignora
  * *INIT*: Se ignora
  * *PRE*: En este _stage_ se ejecutarán por orden los siguientes pasos:
    - Checkout de la rama adecuada del repositorio
    - Análisis del código fuente con SonarQube
    - Construcción de la aplicación (build del fichero .clarive.yml)
    - Test de la aplicación (test del fichero .clarive.yml)
  * *RUN*: En ese _stage_ se ejecuta el despliegue real de la aplicación
previamente construida en el stage *PRE*.  Clarive espera encontrar un
fichero *.war* en el directorio _target_ del path de trabajo para ese
despliegue/repositorio y lo desplegará al servidor Tomcat definido por
el administrador. La URL en la que se podrá probar la aplicación quedará
publicada en el tópico de cambio una vez que finalice correctamente el
despliegue.
  * *POST*: Este stage se ejecutará *siempre* después de *PRE* y *RUN*
incluso cuando alguno de los anteriores haya finalizado con error.

## ¿Por dónde empiezo?

Tal y como ya hemos explicado el objetivo de la práctica es instalar
la aplicación satisfactoriamente la aplicación en el entorno de producción
después de seguir todo el ciclo de vida.

A continuación se listan los pasos _mínimos_ para conseguir este objetivo:

1. Crear un nuevo tópico de tipo __Feature__ para arreglar los incumplimientos
de código que aparecerán en el análisis SonarQube
2. Transitar la nueva __Feature__ al estado __En Progreso__
3. Crear un tópico __Release__ y asignar la __Feature__ a esa release (editar la __Feature__)
y seleccionar la release creada en el campo adecuado
4. Clonar el repositorio de código en local y hacer checkout de la rama que
Clarive ha creado para esa __Feature__
5. Desplegar la __Feature__ al entorno _INTE_ desde el tópico utilizando
el menú _Deploy_. El despliegue va a fallar porque se incumple el modelo
de calidad definido en SonarQube.
6. Revisar el log de despliegue y acceder a los resultados del análisis
a través del link publicado en el log.
7. Arreglar los errores reportados por SonarQube (https://upm-qa.clarive.io/about)
en la copia local del repositorio, confirmar los cambios y actualizar los cambios
de la rama de la feature en el repositorio remoto (push de la rama)
8. Automáticamente se lanzará un despliegue a _INTE_ con los nuevos cambios.
Si se han corregido todos los incumplimientos se desplegará satisfactoriamente.
Si no, habrá que repetir 6 y 7 hasta que se desplegue satisfactoriamente.
9. Transitar el tópico __Feature__ a __In Review__ y validar que la aplicación
funciona tal y como se espera en el entorno (la URL se publicará en el propio tópico)
10. Transitar la feature al estado __Ready__
11. Desplegar la __Release__ al entorno _TEST_ y comprobar que la aplicación funciona
tal y como se espera en la URL publicada en la __Feature__ para ese entorno
12. Transitar la __Release__ a __Ready__
13. Deplegar la __Release__ en _PROD_

Puedes repetir todo el ciclo para una nueva __Release__ haciendo varios cambios en
paralelo, asignando éstos a __Sprints__, repartiendo los cambios entre varios
desarrolladores, cambiando los datos por defecto, seleccionando otros usuarios como
reviewers, etc.  En definitiva, cualquier actividad adicional que realices
servirá para obtener un mayor entendimiento de un ciclo de vida real en un
entorno multi-desarrollador, multi-role y con controles empresariales de la
calidad de las aplicaciones.

## ¿Dónde conseguir ayuda?

- [Documentación de clarive](https://docs.clarive.com)
- [Clarive Community](https://community.clarive.com/)
- [Clarive support email](email://support@clarive.com)

