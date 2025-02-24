# 🚀 Fudo Challenge - API con Cuba.rb

Este proyecto es una API desarrollada con **Cuba.rb** para la gestión de usuarios y productos.  
Implementa autenticación de usuarios y permite la creación y consulta de productos.  
La creación de productos se procesa en segundo plano utilizando **Sidekiq**.

## Información Teórica
La información teórica sobre Fudo, TCP y HTTP se encuentra en la carpeta "theory". Consulta los archivos Markdown correspondientes para obtener más detalles.

## Funcionalidades Principales
✅ Registro y autenticación de usuarios (Permite iniciar sesión y registrar nuevos usuarios con validaciones, utilizando BCrypt para el hash de contraseñas y JWT para la generación de tokens de autenticación)
✅ Obtención de productos
✅ Creación de productos en segundo plano con **Sidekiq**  
✅ Uso de **Redis** como almacenamiento en memoria y cola de trabajos  


## Requisitos
Asegúrate de tener instalados los siguientes programas:

- Docker
- Docker Compose
- Ruby 3.3.0
- Bundler

## 🛠 Instalación

1 - Clonar el repositorio
```sh
git clone https://github.com/tu-usuario/fudo-challenge.git
```

cd fudo-challenge

2 - Instalar dependencias
```sh
bundle install
```


## Levantar el Proyecto

Ejecuta el siguiente comando para construir y correr todos los servicios:

```sh
docker-compose up -d --build
```


Esto iniciará:

- API Cuba.rb en http://localhost:9292
- Redis en redis://localhost:6395/0
- Sidekiq para procesamiento en segundo plano


## Ejecutar Tests

Para correr las pruebas en local:

```sh
RACK_ENV=test REDIS_URL=redis://localhost:6395/1 bundle exec rspec
```

## Detener y Limpiar
```sh
docker-compose down
```


## Get Openapi documentation

Request:
```sh

curl http://localhost:9292/openapi.yaml
```

Response:

```sh
openapi: "3.0.0"
info:
  version: 1.0.0
  title: FUDO Semi Senior Challenge API
paths:
  /login:
    post:
      summary: Iniciar sesión de un usuario
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
      responses:
        "200":
          description: Inicio de sesión exitoso
          content:
            application/json:
              schema:
                type: object
                properties:
                  token:
                    type: string
        "401":
          description: Credenciales inválidas
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
  /register:
    post:
      summary: Registrar un nuevo usuario
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
      responses:
        "201":
          description: Usuario registrado exitosamente
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                  user:
                    type: object
        "400":
          description: Error en el registro
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
                  details:
                    type: array
                    items:
                      type: string
  /products:
    get:
      summary: Retorna una lista de productos
      parameters:
        - in: header
          name: Authorization
          schema:
            type: string
          required: true
        - in: header
          name: Accept-Encoding
          schema:
            type: string
          description: Solicitar codificación gzip para la respuesta (opcional)
      responses:
        "200":
          description: Un arreglo JSON de productos
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
        "401":
          description: Token no válido
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
    post:
      summary: Crear un producto de forma asíncrona
      parameters:
        - in: header
          name: Authorization
          schema:
            type: string
          required: true
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
      responses:
        "201":
          description: Producto en proceso de creación
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
        "401":
          description: Token no válido
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
  /AUTHORS:
    get:
      summary: Obtener información del autor
      responses:
        "200":
          description: Información del autor de la app
          content:
            text/plain:
              schema:
                type: string
```

### Postman Coleecion

https://www.postman.com/valentinopfarherr/workspace/fudo-challenge
