# Terraform

RICORDA: fai il login su azure e seleziona la subscription corretta. La differenza tra il DEV e il PROD è il resource group a cui punti e il terraform state che devono già esistere (sicuramente anche il key vault)

- Fai az login e accedi al portale, scegliendo la subscription
- Crea il resoruce group per il terraform state
- Crea uno storage. Il nome deve essere univoco per cui metti qualcosa di "lungo", es: tfprodstatelorenzo
- Crea il container: terraform-state
- Quando referenzi una risorsa già esistente devi sempre usare _data_
- Puoi mettere tutte le reference di risorse esistenti in `data.tf`

Comandi utili terminale:

- az login
- az account list --output table
- az account show
- az account set --subscription "NOME_SUB"
- az account set -s "NOME_SUB"
- terraform init
- terraform plan
- terraform plan -out=tfplan
- terraform apply
- terraform apply tfplan
- terraform destroy
- terraform force-unlock -lock-id="ID"

Se dovesse andare storto qualcosa fai sempre `terraform destroy` e non cancellare nulla a mano di ciò che crei con Terraform.

Adesso siamo in grado di inizializzare il backend con il nostro Terraform State

```
terraform init
Initializing the backend...
Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

...

Terraform has been successfully initialized!
```

Creo il mio resource groups nella cartella modules - commons e associamo al nome del resource group una `locals.tf`:

```
locals {
  project              = "${var.prefix}-${var.env_short}-${var.location_short}"
  is_prod              = var.env_short == "p" ? true : false
}
```

vediamo che definisco 3 variabili in `variables.tf` che dovranno essere passate dal mio `main.tf`. Altrimenti ottengo un errore del tipo: _The argument "prefix" is required, but no definition was found._ a meno che non abbia un valore di default, es:

```
variable "prefix" {
  type    = string
  default = "lor"
  validation {
    condition = (
      length(var.prefix) < 6
    )
    error_message = "Max length is 6 chars."
  }
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "location_short" {
  type    = string
  default = "we"
}
```

In modules - commons nel file variables.tf trovo le variabili da ambiente da inviare dal mio main ai miei moduli, esempio, in `main.tf` ho:

```
module "commons" {
  source      = "../modules/commons"
  env_short   = local.env_short
}
```

che necessita quindi la creazione di un file `locals.tf` dove sta il mio `main.tf`. Attenzione: i tipi devono essere compatibili, se in `vars` mi aspetto una lista di stringhe non posso passare qualcos'altro!
Quando installo un modulo devo fare `terraform init`.

- Aggiungo la mia VNet:

```
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  resource_group_name = "${local.project}-webapp-rg"
  location            = var.location
  address_space       = var.cidr_vnet
}
```

quindi devo creare una var cidr_vnet e passarla dal `main.tf` che la accede da `locals.tf`:

```
locals {
  prefix    = "lorenzo"
  env_short = "p"
  cidr_vnet = ["10.20.7.32/27"]
}
```

- Creo la mia Azure Web App, se utilizzo un modulo devo rifare `terraform init`

- Per lo slot di staging usare `azurerm_linux_web_app_slot` o `azurerm_windows_web_app_slot` al posto di `azurerm_app_service_slot`:

```
The `azurerm_app_service_slot` resource has been superseded by the
│ `azurerm_linux_web_app_slot` and `azurerm_windows_web_app_slot` resources.
│ Whilst this resource will continue to be available in the 2.x and 3.x
│ releases it is feature-frozen for compatibility purposes, will no longer
│ receive any updates and will be removed in a future major release of the
│ Azure Provider.
```

Interessante come referenziare la risorse interna al modulo dallo slot staging: `module.control_room_wa.id`
vai a guardare quali sono gli output del modulo, in questo caso: https://github.com/pagopa/terraform-azurerm-v3/blob/main/app_service/outputs.tf

Interessante vedere anche l'impostazione di una dipendenza, nel caso in esempio tra la vnet e la subnet: `depends_on = [azurerm_resource_group.rg_webapp]`

Interessante capire come funziona la parte della vnet e dello spazio degli indirizzi.
Sito interessante: https://www.subnet-calculator.com/cidr.php

Cosa sono le Virtual Network (VNet)?
Una VNet (Virtual Network) in Azure è una rete privata all'interno del cloud Azure. Immagina che sia come una rete aziendale interna, ma nel cloud. Serve a:

Connettere tra loro risorse Azure (es. macchine virtuali, database, app).
Controllare chi può accedere alle risorse della rete.
Gestire il traffico tra la rete privata e internet o altre reti.
Esempio pratico:
Hai una macchina virtuale (VM) in Azure e vuoi che comunichi con un database sempre in Azure. Per sicurezza, non vuoi che il database sia accessibile pubblicamente da internet. Con una VNet, puoi collegare VM e database in una rete privata in modo sicuro.

Le Subnet (sotto-reti) sono divisioni di una VNet. Servono a organizzare meglio le risorse dentro la rete.

Esempio:

Hai una VNet chiamata "Rete-Aziendale".
La dividi in due Subnet:
Subnet-FrontEnd: dove metti le app e i server che devono comunicare con internet.
Subnet-BackEnd: dove metti database e risorse interne, che devono rimanere protette.
Perché usare Subnet?
Per separare i ruoli delle risorse e applicare regole diverse di sicurezza. Ad esempio, puoi dire che la Subnet-BackEnd non può essere raggiunta da internet, ma solo dalla Subnet-FrontEnd.

Cosa sono i Private Endpoints e i Service Endpoints?
Ora passiamo ai concetti legati alla sicurezza e alla comunicazione con servizi Azure, come database, storage, ecc.

Service Endpoints
Un Service Endpoint permette alle risorse dentro la tua VNet di comunicare con i servizi Azure (es. un database SQL o un account di storage) in modo sicuro, senza esporre il traffico su internet.

È veloce perché usa la rete Azure interna.
Ma il servizio (es. database) resta comunque pubblico, anche se lo accedi dalla tua VNet.
Esempio pratico:
Una macchina virtuale nella tua VNet deve accedere a un account di storage. Con un Service Endpoint, la VM può accedere direttamente al servizio su rete Azure, senza passare da internet.

Private Endpoints
Un Private Endpoint va oltre il Service Endpoint e garantisce che il servizio Azure (es. database, storage) sia accessibile solo dalla tua VNet, eliminando del tutto la sua esposizione pubblica.

Il servizio ottiene un indirizzo IP privato nella tua Subnet.
Molto sicuro, perché il servizio diventa parte della tua rete privata.
Esempio pratico:
Hai un database SQL. Con un Private Endpoint, quel database può essere raggiunto solo dalla tua VNet (e non da internet) e si comporta come se fosse fisicamente dentro la tua rete.
