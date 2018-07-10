# SkipUFO_infra
SkipUFO Infra repository

# Table of content
- [Homework-3: Cloud-1](#homework-3-cloud-1)
- [Homework-4: Cloud-2](#homework-4-cloud-2)
- [Homework-5: Packer-1](#homework-5-packer-1)
- [Homework-6: Terraform-1](#homework-6-terraform-1)

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
