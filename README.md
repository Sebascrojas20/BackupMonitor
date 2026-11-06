# BackupMonitor 6.0

**Windows Backup Monitoring and Automation**

Herramienta desarrollada en PowerShell para supervisar archivos de respaldo en entornos Windows, identificar novedades y generar reportes de seguimiento.

## Objetivo

Automatizar la verificación de archivos de respaldo mediante una configuración externa, reduciendo las comprobaciones manuales y facilitando el seguimiento de su disponibilidad y antigüedad.

## Funcionalidades

- Verificación de existencia de archivos esperados.
- Detección de respaldos antiguos.
- Identificación de archivos vacíos.
- Detección de fechas de modificación futuras.
- Cálculo de hashes SHA-256.
- Generación de reportes individuales CSV.
- Registro histórico acumulado.
- Archivo de logs.
- Notificaciones nativas de Windows.
- Configuración externa mediante JSON.

## Tecnologías

| Tecnología | Uso |
|---|---|
| PowerShell | Automatización y ejecución |
| Windows | Sistema operativo |
| JSON | Configuración externa |
| CSV | Reportes e historial |
| SHA-256 | Identificación del contenido |

## Estructura del proyecto

```text
BackupMonitor/
├── scripts/
│   └── Verificar-Backups.ps1
├── documentacion/
├── evidencias/
├── ejemplos/
├── config.example.json
└── README.md
```

## Configuración

El proyecto utiliza un archivo JSON externo para separar los parámetros del código.

### Preparación inicial

1. Clonar o descargar el repositorio.
2. Crear una copia de `config.example.json`.
3. Renombrar la copia como `config.json`.
4. Modificar los parámetros según el entorno local.

Ejemplo:

```json
{
    "BackupPath": "C:\\Backups",
    "DiasMaximos": 2,
    "BackupsEsperados": [
        "Backup_DB.bak",
        "Backup_Oracle.trn",
        "Backup_Servidor.zip"
    ]
}
```

### Parámetros

- `BackupPath`: directorio donde se encuentran los archivos.
- `DiasMaximos`: antigüedad máxima permitida.
- `BackupsEsperados`: nombres de los archivos que deben supervisarse.

**Importante:** `config.json` contiene parámetros locales y está excluido del repositorio mediante `.gitignore`. El archivo público `config.example.json` sirve como plantilla.
## Estados supervisados

| Estado | Descripción |
|---|---|
| OK | Archivo existente y dentro del límite de antigüedad |
| ANTIGUO | Archivo que supera la antigüedad permitida |
| FALTANTE | Archivo esperado que no existe |
| VACÍO | Archivo sin contenido |
| ERROR | No fue posible verificar el archivo |
| FECHA_FUTURA | Fecha de modificación posterior a la ejecución |

## Reportes generados

Los resultados se almacenan en una carpeta `Reportes` dentro del directorio configurado en `BackupPath`.

- `Reporte_Backups_*.csv`: resultado de cada ejecución.
- `Historial_Backups.csv`: histórico acumulado.
- `BackupMonitor.log`: registro de eventos.

## Seguridad e integridad

El sistema calcula el hash SHA-256 de los archivos no vacíos que puede leer.

Este valor permite identificar el contenido de un archivo, pero por sí solo no demuestra que el respaldo sea íntegro o restaurable. Para validar la recuperación se requieren pruebas de restauración independientes.

La herramienta no sustituye una política de copias de seguridad ni una estrategia de recuperación ante desastres.

## Pruebas realizadas

Se ejecutaron pruebas en un entorno de laboratorio con archivos de prueba:

- Detección de archivos existentes.
- Identificación de un archivo faltante.
- Verificación de antigüedad.
- Detección de archivos vacíos.
- Cálculo de hashes SHA-256.
- Generación de reportes CSV.
- Registro histórico y logs.
- Notificaciones de Windows.
- Lectura de configuración externa JSON.

En la última ejecución documentada:

| Resultado | Cantidad |
|---|---:|
| Archivos esperados | 3 |
| Correctos | 2 |
| Faltantes | 1 |
| Antiguos | 0 |
| Errores | 0 |
| Disponibilidad | 66.67 % |

Las pruebas utilizaron archivos de laboratorio, no respaldos reales de producción. No se ha certificado la restauración de copias reales.

## Mejoras futuras

- Validación automatizada de restauraciones.
- Reportes HTML.
- Integración con correo electrónico.
- Centralización de resultados.
- Monitoreo remoto de múltiples servidores.
- Gestión de alertas y umbrales.

## Estado del proyecto

**Versión:** 6.0
**Estado:** Proyecto funcional en laboratorio
**Lenguaje:** PowerShell
**Plataforma:** Windows

---

Desarrollado como proyecto práctico de automatización y administración de infraestructura TI.
