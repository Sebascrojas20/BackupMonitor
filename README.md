# 📦 BackupMonitor v6.0

### Automatización y verificación de respaldos mediante PowerShell

BackupMonitor es una herramienta desarrollada en PowerShell que permite automatizar la verificación del estado de los respaldos de información, identificar archivos faltantes o desactualizados y generar reportes para facilitar el seguimiento de los procesos de backup.

Su objetivo es mejorar el control de los respaldos mediante validaciones automáticas, registro histórico y generación de alertas sobre posibles novedades.

---

## 🎯 Objetivo del proyecto

Facilitar la supervisión de los respaldos mediante un proceso automatizado que permita identificar oportunamente problemas de disponibilidad, antigüedad e integridad de los archivos.

---

## ⚙️ Funcionalidades principales

- Verificación automática de archivos de respaldo.
- Identificación de archivos faltantes.
- Detección de respaldos desactualizados.
- Validación de integridad mediante SHA-256.
- Configuración de antigüedad máxima permitida.
- Generación de reportes en formato CSV.
- Registro histórico de verificaciones.
- Generación de logs de ejecución.
- Posibilidad de programación mediante el Programador de tareas de Windows.
- Configuración externa mediante archivos JSON.

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Aplicación |
|---|---|
| PowerShell | Automatización y ejecución de validaciones |
| JSON | Configuración de parámetros |
| CSV | Generación de reportes |
| SHA-256 | Verificación de integridad |
| Windows Task Scheduler | Programación de ejecuciones |

---

## 📁 Estructura del proyecto

```text
BackupMonitor/
│
├── Verificar-Backups.ps1
├── config.example.json
├── .gitignore
├── README.md
│
├── reportes/
├── logs/
├── historial/
└── tareas/
```

*Los directorios de reportes, logs e historial se utilizan para almacenar los resultados generados durante la ejecución, según la configuración del proyecto.*

---

## 📋 Requisitos

- Windows 10 o Windows Server.
- Windows PowerShell 5.1 o superior.
- Permisos de lectura sobre las carpetas donde se almacenan los respaldos.
- Archivos de configuración JSON.
- Espacio disponible para almacenar reportes e históricos.

---

## 🚀 Instalación

1. Clonar el repositorio:

```powershell
git clone https://github.com/Sebascrojas20/BackupMonitor.git
```

2. Entrar al directorio:

```powershell
cd BackupMonitor
```

3. Crear la configuración local a partir del ejemplo:

```powershell
Copy-Item config.example.json config.json
```

4. Editar `config.json` y establecer las rutas correspondientes a los respaldos que se desean supervisar.

---

## 🔧 Configuración

BackupMonitor utiliza un archivo JSON para definir los parámetros de verificación.

El archivo `config.example.json` contiene una plantilla de configuración que debe adaptarse al entorno donde se ejecutará la herramienta.

Entre los parámetros configurables se encuentran:

- Ubicación de los archivos de respaldo.
- Nombres de los archivos esperados.
- Antigüedad máxima permitida.
- Parámetros de validación.

**Nota:** No publiques credenciales, rutas internas ni información sensible en el repositorio.

---

## ▶️ Ejecución

Desde PowerShell, ejecutar:

```powershell
.\Verificar-Backups.ps1
```

El script realizará las validaciones configuradas y generará los resultados correspondientes.

Si Windows bloquea la ejecución del script, revisa la política de ejecución y utiliza únicamente los permisos autorizados en tu entorno.

---

## 📊 Resultados esperados

La herramienta permite identificar diferentes estados de los respaldos:

| Estado | Descripción |
|---|---|
| OK | El respaldo cumple las validaciones |
| FALTANTE | No se encontró el archivo esperado |
| DESACTUALIZADO | El respaldo supera la antigüedad permitida |

Los resultados se registran para facilitar el seguimiento y la revisión de las ejecuciones.

---

## 🔐 Seguridad

El proyecto incorpora buenas prácticas para proteger la información:

- Configuración de ejemplo independiente de la configuración local.
- Exclusión de archivos de configuración privados.
- Validación de integridad mediante SHA-256.
- Evitar publicar credenciales o rutas internas.
- Registro de resultados para facilitar auditorías operativas.

---

## 💡 Aplicación práctica

BackupMonitor representa una solución de automatización orientada a tareas de administración de infraestructura TI.

Permite reducir las verificaciones manuales, mejorar la visibilidad sobre el estado de los respaldos y facilitar la identificación de novedades que requieren atención.

---

## 👨‍💻 Autor

**Sebastián Rojas**

Técnico en Sistemas | Estudiante de Ingeniería de Sistemas

Intereses profesionales:

- Infraestructura TI.
- Administración de servidores.
- Automatización con PowerShell.
- Bases de datos Oracle.
- Cloud Computing.

🔗 [GitHub](https://github.com/Sebascrojas20)

---

*Proyecto desarrollado con fines de aprendizaje, automatización y fortalecimiento de habilidades profesionales en infraestructura tecnológica.*
