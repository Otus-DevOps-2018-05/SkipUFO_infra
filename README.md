# SkipUFO_infra
SkipUFO Infra repository

# Table of content
- [Homework-3: Cloud-1](#homework-3-cloud-1)
- [Homework-4: Cloud-2](#homework-4-cloud-2)
- [Homework-5: Packer-1](#homework-5-packer-1)
- [Homework-6: Terraform-1](#homework-6-terraform-1)
- [Homework-7: Terraform-2](#homework-7-terraform-2)
- [Homework-8: Ansible-1](#homework-8-ansible-1)
- [Homework-9: Ansible-2](#homework-9-ansible-2)
- [Homework-10: Ansible-3](#homework-10-ansible-3)

# Homework-3: Cloud-1
## 1.1 Что было сделано
  - Создан и импортирован в metadata проекта Infra ключ пользователя appuser
  - Созданы 2 instance (с внешним IP, только с внутренним IP)
  - Создан туннель для ssh доступа ко внутреннему ресурсу через внешний
  - Развернут vpn (setupvpn.sh)
  - ДЗ выполнено в полном объеме

### Получение доступа к внутренним ресурсам через ресурс с внешним доступом (DMZ?)
1. Создаем ключи для доступа ко внутренним ресурсам и ресурсу, через 
   который будет доступ ко внутренним ресурсам (не забываем, что с 
   внешнего должен быть доступ ко внутренним ресурсам)
2. Запускаем на локальной ОС tcp-forwarding
   ssh -i ~/.ssh/appuser -f -N -L 2222:<internal_ip>:22 appuser@<external_ip>
3. Для доступа используем команду
   ssh -p 2222 appuser@localhost

### Настройка алиаса соединения
  В файл ~/.ssh/config вносим информацию о подключении к внутреннему ресурсу
  Host     internal_otus # название внутреннего ресурса
  User     appuser       # имя пользователя, которым заходим на внутренний ресурс
  Port     2222          # порт для ssh-доступа
  HostName localhost     # имя хоста

### Настройка VPN
bastion_IP = 35.228.89.200
someinternalhost_IP = 10.166.0.3

# Homework-4: Cloud-2
## 1.1 Что было сделано
  - Настроена утилита gcloud для работы с облаком GCP
  - Создан instance при помощи gcloud
  - Изучено автоматическое развертывание приложения, используя startup_script, при создании instance, в том числе из скрипта, находящегося в bucket
  - ДЗ выполнено в полном объеме

### Создание VM с deploy приложения
(Использование startup-script https://cloud.google.com/compute/docs/startupscript)

1. Использование локального файла с ОС, с которой запускается команда gcloud
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-from-file startup-script=startup_script.sh
```
startup_script.sh в репозитории
2. Использование файла из bucket
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url startup-script=gs://bucket/startup_script.sh
```

### Настройка puma-server 
testapp_IP = 35.228.187.101
testapp_port = 9292

# Homework-5: Packer-1
## 1.1 Что было сделано
  - Установлен и настроен packer
  - Создан образ с установленными mongodb, ruby (ubuntu16)
  - Создан образ с развернутым приложением на основе образа ubuntu16
  - ДЗ выполнено в полном объеме

### Создание образа VM при помощи packer

Создание образа запускается командой
packer build [OPTIONS] file.json

В папке packer приведены файлы 2 образов 
ubuntu16 - mongo + ruby
immutable - ubuntu16 + app (Задание со *)

Рассмотрено использование переменных (параметров) для создания образов VM (variables)
-var 'key=value' - при использовании в команде
-var-file file.json - при использовании файла с переменными

# Homework-6: Terraform-1
## 1.1 Что было сделано
  - Установлен и настроен terraform
  - Создан проекта описания инфраструктуры
  - Создано описание развертывания инстанса с установленным приложением
  - ДЗ выполнено в полном объеме
  - В рамках заданий со * описано создание балансировщика на один инстанс, на группу инстансов, изучено использование шаблонов инстансов (instance_template), менеджера групп инстансов (instance_group_manager)


### Структура проекта описания инфраструктуры
Всё описание инфраструктуры хранится в файлах tf (инфраструктура), tfvars (переменные)

Описание разделяем логически на 3 файла 
main      - непосредственно инфраструктура
variables - описание input переменных
output    - описание output переменных

### Описание инфраструктуры
Обязательно сначала описываем блок provider - который будет означать платформу запуска
Каждый ресурс (vm, firewall rules, metadata) описывается отдельным блоком resource и зависит от платформы запуска

ВАЖНО. Для GCP (и скорее всего для любой платформы) данные перезаписываются (т.е. если мы зальем через web-интерфейс ключи, и потом тоже самое через терраформ, то ключи добавленные через web-интерфейс будут удалены)

### Как запустить
terraform apply - запуск 
terraform plan - посмотреть изменения

### Задания со *
На всё задание ушло больше 1 дня. Достаточно тяжело оказалось подобрать необходимые для работы балансировщика примитивы google_compute, например, tcp балансировщик умеет работать только с определенными портами, для некоторых примитивов типа pool, group в качестве healthcheck может быть только http_health_check. 

В итоге пришел к такой схеме: 
instance -> target_pool -> forwarding_rule (не global) (port_range)
              ^
              |
http_health_check (port)

# Homework-7: Terraform-2
## 1.1 Что было сделано
 - Развернута инфраструктура из прошлого ДЗ (instance + app + firewall (port = 9292))
 - Добавлена информация в state о ресурсе, созданном не из terraform (terraform import ресурс), после чего необходимо выполнить terraform apply. Т.е. команда import ищет в текущей инфраструктуре ресурс с указанным именем и сохраняет его state себе, а потом применяем описание из наших tf-файлов.
 - Сделано создание статического адреса отдельным ресурсом и добавление его инстансу
 - Созданы образы с mongodb и с приложением (разделен образ reddit-full на 2)
 - Файл main.tf был разделен на отдельные логические блоки - app, db, vpc
 - Логические блоки app, db, vpc переделаны в в модули (terraform modules)
 - Добавлена параметризация модуля vpc
 - Проверена правильность использования параметризации модуля vpc (доступ только со своего IP)
 - Сделано разделение на prod и stage инфраструктуру
 - Добавлен параметр machine type для инстансов с db и app
 - Созданы 2 bucket в Google Cloud Storage (ВНИМАНИЕ. Очень важно не путать region и zone, случайно в region написал europe-west1-b, terraform возвращал, что невалидный параметр, но не говорил какой)
 - В stage, prod созданы конфигурации для удаленного хранения tfstate файлов
 - Настроены provisioners для модуля app (ВАЖНО. Для копирования файлов нужно использовать в пути ${path.module}/)
 - Для запуска приложения в puma.service была добавлена установка переменной окружения DATABASE_URL внутренним ip-адресом интанса reddit-db
 - Для возможности подключения к БД в /etc/mongod.conf была проведена замена 127.0.0.1 на 0.0.0.0 (ПРИМЕЧАНИЕ. По-хорошему надо бы также как в случае с reddit-app передавать адрес приложения, чтобы открыть ему доступ, на уровне модуля db так не получится, скорее всего надо запустить из модуля app  provisioner к db-хосту с заменой не на 0.0.0.0, а на нужный IP)
 - Изучено, что для условных операций нужно использовать count (count используется как цикл, и, соответственно, при 0 декларации не применяются). null_resource можно использовать, например, для выполнения скриптов

# Homework-8: Ansible-1
## 1.1 Что было сделано
 - Установлен ansible (использовал apt install ansible / на ubuntu 18.04)
 - Создан файл inventory.yml с перечислением хостов, с которыми будет происходить работа (reddit-app, reddit-db поднятые из terraform/stage)
 - Изучены модули ansible - command (выполнение одной команды), shell (выполнение shell-скрипта), systemd/service (name=mongod)
 - Создан playbook для клонирования репозитория. Когда запускаем с уже клонированным репозиторием, то ansible вернет - ОК и напишет, что не было изменений, после удаления репозитория и выполнения того же playbook ansible покажет, что по таску были изменения и в общей статистике укажет, что по appserver были изменения. 

 ## 1.2 Задание со *
 - Изучено создание скрипта для получения динамического inventory (py-скрипт должен обрабатывать входной параметр --list, и минимально возвращать json в формате { "group_name": { "hosts": [<hosts>]} }), также файл *.py должен быть исполняемым

# Homework-9: Ansible-2
## 1.1 Что было сделано
 - Создан playbook для настройки mongo, развертывания приложения
 - Изучено применение templates для подстановки необходимых параметров
 - Сделано разделение одного playbook на несколько
 - Сделано разделение на разные файлы - такой подход позволяет уменьшить использование тегов при запуске playbook
## 1.2 В задании со *
 - Была найдена статья https://alex.dzyoba.com/blog/terraform-ansible/, в которой предлагается:
   если для развертывания инфраструктуры (GCP) используется terraform, то можно сформировать dynamic inventory из tfstate, и не использовать gce.py. 
   В общем же случае, можно написать скрипт, который из любого хранилища (хоть excel), сможет сформировать dynamic inventory

# Homework-10: Ansible-3
## 1.1 Что было сделано
 - Созданы "шаблоны" ролей (ansible-galaxy init <имя роли>)
 - Перенесены описания playbook развертывания app, db в соответствующие роли
 - Сделано удобное разделение вызова нужного окружения (используя папку environments/stage(prod)), для того чтобы явным образом раскатывать playbook на нужной инфраструктуре (по-умолчанию в ansible.cfg сделан stage)
 - Созданы групповые переменные (group_vars) (Директория group_vars, созданная в директории плейбука или инвентори файла, позволяет создавать файлы (ВАЖНО! имена, которых должны соответствовать названиям групп в инвентори файле) для определения переменных для группы хостов.) 
 - Согласно рекомендации (best practice) сделана следующая структура: файлы - ansible.cfg, requirements.txt, папки - roles, playbooks, environments
 - Для подключения использования ролей, в ansible.cfg прописывается roles_path
 - Попробовано использование хранилища ролей Ansible Galaxy (использована роль для настройки проксирования nginx)
 - Изучена работа с ansible vault (использование vault.key с настройкой в ansible.cfg - vault_password_file). Чтобы зашифровать нужно использовать ansible-vault encrypt <имя файла>, для редактирования ansible-vault edit <имя файла>, для расшифровки ansible-vault decrypt <имя файла>
## 1.2 В самостоятельном задании
 - В описании инфраструктуры terraform порт 9292 файрвола puma-firewall изменен на 80 (в модуле app)
## 1.2 В задании со *
 - Была найдена статья https://alex.dzyoba.com/blog/terraform-ansible/, в которой предлагается:
   если для развертывания инфраструктуры (GCP) используется terraform, то можно сформировать dynamic inventory из tfstate, и не использовать gce.py. 
   В общем же случае, можно написать скрипт, который из любого хранилища (хоть excel), сможет сформировать dynamic inventory
