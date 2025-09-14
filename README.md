# IaC com Terraform e Google Cloud: Deploy de Site Estático com Ansible

<h3>Desafio Hands On do BootCamp de DevOps da Atlântico Avanti</h3>

<p>O desafio consiste em realizar o processo de provisionamento da infra em um Provider via Terraform  e por último o deploy do site</p>
<p>Para este desafio escolhi o Google Cloud e criei o site de Boas Vindas que está no repositório: https://github.com/JessicaApBueno/BoasVindasGCP </p>


<h4>A entrega será feita com o envio das seguintes evidências:</h4>

Captura de tela do Terraform rodando
![terraformcriouVM](https://github.com/user-attachments/assets/dbf3334b-a6f8-4c28-82fd-383dbe4a77ad)


Captura de tela da página abaixo rodando
![webserver funcionando](https://github.com/user-attachments/assets/2136582b-4b65-495b-aee0-cba73b200efb)

![webserver funcionando2](https://github.com/user-attachments/assets/47ab5ea9-65a3-47db-b3e9-e1dc8de98015)

Captura do Playbook.yml rodando
![playbookrodando](https://github.com/user-attachments/assets/4e8f40f2-e2eb-4dc6-8df9-f6de800a4ca6)
![playbookok](https://github.com/user-attachments/assets/fae14fe3-a184-4757-a603-524bebe50863)

Captura do Terraform Destruindo
![terraformdestruindo](https://github.com/user-attachments/assets/521c8567-9398-4ecd-9ffd-021f9b991a9b)
![terrafordestroyok](https://github.com/user-attachments/assets/2b0fc80a-e6af-4116-95ed-2b2444eea6d6)

<h4>Este projeto demonstra um fluxo completo de Infraestrutura como Código (IaC) para provisionar uma máquina virtual (VM) no Google Cloud Platform (GCP) usando Terraform e, em seguida, configurá-la como um servidor web com Ansible para hospedar um site estático. </h4>

# Visão Geral da Arquitetura
O fluxo de trabalho é o seguinte:

O desenvolvedor executa os comandos do Terraform em sua máquina local.

O Terraform se comunica com as APIs do Google Cloud para criar a infraestrutura definida nos arquivos .tf (VM, regras de firewall, etc.).

Após a criação da infraestrutura, o Ansible se conecta à nova VM via SSH.

O Ansible executa um playbook para instalar e configurar o Nginx, clonar um repositório Git com o site e publicar os arquivos.

O usuário final acessa o site através do IP público da VM.

# 🚀 Funcionalidades
☁ Infraestrutura como Código: Toda a infraestrutura do GCP é definida em código Terraform, permitindo que seja criada, alterada e destruída de forma consistente e reproduzível.

☁ Gerenciamento de Configuração: O Ansible é usado para automatizar a configuração do servidor, garantindo que o ambiente seja configurado corretamente, sem intervenção manual.

☁ Implantação Automatizada: O playbook do Ansible clona o código-fonte de um site diretamente de um repositório Git, automatizando o processo de deploy.

☁ Segurança: Utiliza um par de chaves SSH para acesso seguro à VM e regras de firewall que limitam o acesso SSH a um IP específico.

# 🔧 Pré-requisitos
Antes de começarmos, você precisará ter algumas ferramentas instaladas e contas configuradas.

→ Instalação Ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

→ Instalação do Terraform:

Acesse o site oficial para baixar e instalar o Terraform: [developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

→ Instalação do Google Cloud SDK (gcloud CLI):

Esta é a ferramenta de linha de comando para interagir com o Google Cloud. Siga o guia de instalação oficial: [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)

→ Criar um projeto no Google Cloud:

Toda a infraestrutura no GCP vive dentro de um projeto. Se você ainda não tem um, crie um novo projeto no Console do Google Cloud. Anote o ID do Projeto, pois você precisará dele.

→ Realizar login com o gcloud CLI:

Abra seu terminal e execute os seguintes comandos para autenticar sua conta e configurar seu projeto padrão:

```bash

gcloud auth login
gcloud config set project SEU_PROJECT_ID

```
⚠︎ Substitua SEU_PROJECT_ID pelo ID do seu projeto.

→ Habilitar as APIs necessárias:

O Terraform precisará de permissão para criar recursos. Habilite a API do Compute Engine:

```bash

gcloud services enable compute.googleapis.com

```
# ⚙️ Configuração
Clone este repositório:

```Bash

git clone https://github.com/JessicaApBueno/IACcomTerraformAndGCP.git
cd IACcomTerraformAndGCP

```

# 🚀 Passo a Passo da Execução
Inicialize o Terraform:
Este comando prepara seu diretório de trabalho, baixando os provedores necessários.

```Bash

terraform init
```

Planeje e Aplique a Infraestrutura:
Execute apply para que o Terraform crie os recursos no GCP. Revise o plano e digite yes quando solicitado.

```Bash

terraform apply
```
Ao final, o Terraform exibirá o IP público da instância.

Configure o Inventário do Ansible:
O arquivo de inventário (inventory) informa ao Ansible onde e como se conectar. Adicione a seguinte linha a ele, substituindo <IP_PUBLICO_DA_VM> pelo IP gerado no passo anterior.

```Bash
# Exemplo: 34.55.253.163 ansible_user=devops ...
<IP_PUBLICO_DA_VM> ansible_user=devops ansible_ssh_private_key_file=gcp-instance-key.pem
```
Crie o  Playbook do Ansible:

```Bash
nano playbook.yml
```
Cole o código:
```Bash
---
- name: Configure Web Server Locally
  hosts: all
  become: yes
  tasks:
  
    - name: Stop and disable apt-daily services
      systemd:
        name: "{{ item }}"
        state: stopped
        enabled: no
      loop:
        - apt-daily.service
        - apt-daily-upgrade.service
        - apt-daily.timer
      ignore_errors: yes # Ignora o erro se algum serviço não existir

    - name: Ensure apt cache is updated
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Ensure all packages are up to date
      apt:
        upgrade: dist

    - name: Install Git
      apt:
        name: git
        state: present

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Ensure Nginx service is started and enabled
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Remove default Nginx page (if it exists)
      file:
        path: /var/www/html/index.nginx-debian.html
        state: absent

    - name: Clone BoasVindasGCP repository
      git:
        repo: 'https://github.com/JessicaApBueno/BoasVindasGCP.git'
        dest: '/tmp/website'
        clone: yes
        force: yes

    - name: Deploy website files to Nginx document root
      copy:
        src: "/tmp/website/"
        dest: "/var/www/html/"
        remote_src: yes
        owner: root
        group: www-data
        mode: '0755'
      notify:
      - restart nginx

  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```
Pressione  Ctrl  + x + y + Enter

Execute o comando:

```bash
ansible-playbook -i inventory playbook.yml
```

Acesse seu Site!
Após a conclusão do playbook, seu site estará no ar. Acesse-o usando http:// no navegador.
http://<IP_PUBLICO_DA_VM>

# 📁 Estrutura do Projeto

```bash
.
├── compute.tf                 # Define a VM do Google Compute Engine.
├── firewall.tf                # Define as regras de firewall (liberar portas 80 e 22).
├── gcp-instance-key.pem       # (Gerado pelo Terraform) Chave SSH privada para acessar a VM.
├── inventory                  # Arquivo de inventário do Ansible.
├── outputs.tf                 # Define os dados de saída do Terraform (ex: IP público).
├── playbook.yml               # Playbook do Ansible para configurar o servidor.
├── provider.tf                # Define o provedor (Google Cloud) e suas configurações.
├── ssh_key.tf                 # Gera o par de chaves SSH e salva a chave privada.
├── terraform.tfvars.example   # Arquivo de exemplo para as variáveis do projeto.
├── variables.tf               # Declara as variáveis usadas pelo Terraform.
└── .gitignore                 # Especifica arquivos a serem ignorados pelo Git (ex: *.pem).
```
# 🧹 Limpeza

```bash

terraform destroy
```
