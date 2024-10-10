
## PRUEBA BHD

Se intentó implementar la herramienta Sandbox de Azure para realizar la prueba, pero los entornos de prueba no cuentan con los permisos necesarios para ejecutar el comando `terraform apply`. Adicinalmente, actualmente no dispongo de una tarjeta de crédito para utilizar una cuenta de Azure real.

A pesar de estas limitaciones, fue posible ejecutar los comandos `terraform init` y `terraform plan` dentro del Sandbox, lo que permitió verificar la configuración y asegurarse de que no hubiera errores en el código de despliegue. Estos comandos son útiles para revisar y validar la infraestructura antes de intentar aplicarla en un entorno con los permisos adecuados.

### Pasos para usar la Sandbox:

1. Dirígete al siguiente enlace: [Ejercicio de creación de una cuenta de almacenamiento en Azure](https://learn.microsoft.com/en-us/training/modules/create-azure-storage-account/5-exercise-create-a-storage-account?source=learn).
   
2. Desplázate hacia abajo en la página y busca la opción para iniciar la Sandbox. Deberás verificar tu cuenta antes de poder usarla. Cada Sandbox tiene un límite de uso de **4 horas**, tras lo cual tendrás que iniciar una nueva.

3. Ya creada la sandbox puedes ingresar a Azure portal desde la opcion que se encuentra un poco mas abajo en el mismo enlace.

## Instalación del Azure CLI en Windows
Para interactuar con Azure desde la línea de comandos, es necesario instalar el Azure CLI. A continuación, se detallan los pasos para instalarlo en Windows:

1. Descarga el instalador:

   Visita la página de descarga de Azure CLI: [Instalación de Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli).

   Haz clic en el enlace de descarga para el instalador de Windows.

2. Ejecuta el instalador:

   Abre el archivo descargado y sigue las instrucciones en pantalla para completar la instalación.

3. Verifica la instalación:

   Abre una terminal de comandos (CMD) y ejecuta el siguiente comando `az --version`

## Inicio de sesión en Azure (az login)

Una vez instalado el Azure CLI, el siguiente paso es iniciar sesión en tu cuenta de Azure para poder gestionar recursos. Para ello, utiliza el siguiente comando: `az login`

## Obtener información de la suscripción y tenant (az account show)

Después de iniciar sesión, es recomendable verificar tu información de cuenta. Ejecuta el siguiente comando: `az account show`


