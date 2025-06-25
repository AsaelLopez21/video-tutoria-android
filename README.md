# proyecto_android_videollamada

Un proyecto de NovaUniversitas

##Información del proyecto

Este proyecto intenta crear una conexión entre estudiantes y profesores.

Se usa el framework flutter-dart para crear la interfaz en el teléfono movil, 
la base de datos se despliega en firebase donde guardamos información sobre el 
usuario, pantallas de login y registro para los usuarios, pantallas de calendario,
pantalla para agregar, editar y eliminar contactos, pantalla similar para agregar,
editar y eliminar notas del usuario.


Las funcionalidades principales incluyen:  
- Pantallas de login y registro
- Gestión de tutorados (agregar, eliminar).  
- Gestión de anuncios para el profesor.  
- Calendario.
- Videollamadas entre profesores y estudiantes.

## Instalación

### Para usuarios finales  
- Descarga e instala la APK desde el siguiente enlace:
  https://drive.google.com/drive/folders/1yOvp7iBqh15Gui1iZbIC_DQMjr74_TA9?usp=sharing
- Habilita la instalación para archivos APK.
- Da permisos necesarios de audio y vídeo.
- Regístrate.

### Para desarrolladores  
1. Clona el repositorio:
 https://github.com/AsaelLopez21/video-tutoria-android  
2. Navega a la carpeta del proyecto 
3. Instala las dependencias:
   npm flutter pub get
4. Ejecutalo en un emulador
   
## Tecnologías utilizadas

- Flutter y Dart para la aplicación.  
- Firebase para base de datos, y almacenamiento de videollamadas.
- Firebase auth para gestión de usuarios
- WebRTC para conectar la videollamada.

## Cómo usar

- Regístrate con datos requeridos.
- Agregar tutorados por matrícula.
- Gestionar asesorados y notas para profesor.
- Alumnos solo visualizan información de su tutor y anuncios si tienen tutor asignado.
- Profesor inicia video llamada, alumno contesta.
