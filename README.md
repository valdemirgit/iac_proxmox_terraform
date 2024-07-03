O Proxmox VE é uma plataforma para executar máquinas e contêineres virtuais. É Baseado no Debian Linux, e completamente open source. Para o máximo flexibilidade, implementamos duas tecnologias de virtualização - Máquina virtual baseada em kernel (KVM) e virtualização baseada em contêiner (LXC).
Um dos principais objetivos do projeto era tornar a administração tão fácil quanto É possível. Você pode usar o Proxmox VE em um único nó ou montar um cluster de Muitos nós. Todas as tarefas de gerenciamento podem ser feitas usando nossa web interface de gerenciamento, e até mesmo um usuário novato pode configurar e instalar Proxmox VE em poucos minutos.

Clone de Proxmox: 

O que é proxmox-cloneO construtor de empacotador é capaz de criar novas imagens para uso com Proxmox em todo o caso. O construtor leva um virtual modelo de máquina, executa qualquer aprovisionamento necessário na imagem após lançá-lo, Em seguida, cria um modelo de máquina virtual. Este modelo pode então ser usado para criar novas máquinas virtuais dentro do Proxmox.

Os discos são especificados em um proxmox-cloneConfiguração do construtor irá substituir discos que já estão presentes no modelo de VM clonado. Se você quiser reutilizar os discos da VM clonada, não especifique discos na sua configuração.

O construtor não gerencia modelos. Uma vez que cria um modelo, ele está para cima para você usá-lo ou excluí-lo.

Você pode gerar seu token-id e segredo de token usando o seguinte comando no seu Proxmox Shell pveum user token add terraform-prov@pve terraform-token --privsep=0Substitua terraform-prov-pve com o seu nome de usuário criado Escreva isso porque você não será capaz de encontrar este token de acesso novamente mais tarde

Packer - O Packer é uma ferramenta de código aberto da Hashicorp para criar imagens de máquinas e contêineres, que automatiza o processo de construção, provisionamento e embalagem dessas imagens, facilitando o gerenciamento e a implantação de sua infraestrutura.

Visão geral
Ao combinar o Proxmox com o Packer, podemos criar infraestrutura como código ou IaC para obter processos de implantação simplificados e automatizados.


Usando o Packer para criar uma imagem de servidor ubuntu-24.04-desktop-amd64.iso dentro do Proxmox. Isso foi projetado com a versão "3.0.1-rc1" Proxmox Virtual Environment.


Obtendo a configuração de arquivos adequados

Existem dois arquivos principais que precisam ser configurados.

O primeiro dos dois é o nosso arquivo credentials.pkr.hcl. Atualize todas as variáveis para o seu próprio. 


pm_api_url = "https://yourProxmox.server:8006/api2/json"
pm_api_token_id = "full-tokenid" 
pm_api_token_secret = "tokenValue"
pm_node = "nodeToBuildOn"
pm_storage_pool = "storagePoolToBuildOn"
pm_storage_pool_type = "typeOf-pm_storage_pool"

ssh_username = "yourSshUser"
ssh_password = "yourSshPassword"
ssh_private_key_file = "~/.ssh/id_rsa"

name        = "K8s.ubuntu"
target_node = "pve"
vmid        = "102"
iso         = "local:ubuntu-24.04-desktop-amd64.iso"


Qualquer configuração mais aprofundada pode ser feita dentro do arquivo ubuntu-desktop-focal.pkr.hcl.
#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: en
  ssh:
    install-server: true
    allow-pw: true
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  packages:
    - qemu-guest-agent
    - sudo
  storage:
    layout:
      name: direct
    swap:
      size: 0
  user-data:
    package_upgrade: false
    timezone: America/New_York
    users:
      - name: username-here
        groups: [adm, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        # passwd: your-password
        # - or -
        # ssh_authorized_keys:
        #   - your-ssh-key


Por fim, o processo Packer

A primeira coisa que devemos fazer antes de ir mais longe, é verificar a dupla avaliação dos nossos arquivos Packer. Caso contrário, podemos ter uma grande dor de cabeça.

    cd no diretório do projeto (./ubuntu-desktop-focal), e executar packer validate -var-file='..\credentials.pkr.hcl' .\ubuntu-desktop-focal.pkr.hcl
        Se algum erro aparecer, você terá que corrigi-los antes de seguir em frente

Uma vez que confirmamos que tudo parece correto, podemos executar a construção, cruzar os dedos, e deve funcionar.

    Construa a imagem (no mesmo diretório do projeto onde você executou o validate), packer build -var-file='..\credentials.pkr.hcl' .\ubuntu-desktop-focal.pkr.hcl

                                                                                                      fonte:https://www.cinderblock.tech/p/packer-proxmox-ubuntu-server-creation
