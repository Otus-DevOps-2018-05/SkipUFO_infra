# SkipUFO_infra
SkipUFO Infra repository

# Получение доступа к внутренним ресурсам через ресурс с внешним доступом (DMZ?)

1. Создаем ключи для доступа ко внутренним ресурсам и ресурсу, через 
   который будет доступ ко внутренним ресурсам (не забываем, что с 
   внешнего должен быть доступ ко внутренним ресурсам)
2. Запускаем на локальной ОС tcp-forwarding
   ssh -i ~/.ssh/appuser -f -N -L 2222:<internal_ip>:22 appuser@<external_ip>
3. Для доступа используем команду
   ssh -p 2222 appuser@localhost

# Настройка алиаса соединения
  В файл ~/.ssh/config вносим информацию о подключении к внутреннему ресурсу
  Host     internal_otus # название внутреннего ресурса
  User     appuser       # имя пользователя, которым заходим на внутренний ресурс
  Port     2222          # порт для ssh-доступа
  HostName localhost     # имя хоста

# Настройка VPN

bastion_IP = 35.228.89.200
someinternalhost_IP = 10.166.0.3

# Настройка puma-server (hw4)

testapp_IP = 35.228.187.101
testapp_port = 9292

# Создание VM с deploy приложения
(Использование startup-script https://cloud.google.com/compute/docs/startupscript)

1. Использование локального файла с ОС, с которой запускается команда gcloud

gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-from-file startup-script=startup_script.sh

startup_script.sh в репозитории
2. Использование файла из bucket

gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url startup-script=gs://bucket/startup_script.sh

# Создание образа VM при помощи packer

Создание образа запускается командой
packer build [OPTIONS] file.json

В папке packer приведены файлы 2 образов 
ubuntu16 - mongo + ruby
immutable - ubuntu16 + app (Задание со *)

Рассмотрено использование переменных (параметров) для создания образов VM (variables)
-var 'key=value' - при использовании в команде
-var-file file.json - при использовании файла с переменными

# Создание инфраструктуры при помощи terraform

Всё описание инфраструктуры хранится в файлах tf (инфраструктура), tfvars (переменные)

Описание разделяем логически на 3 файла 
main      - непосредственно инфраструктура
variables - описание input переменных
output    - описание output переменных

Обязательно сначала описываем блок provider - который будет означать платформу запуска
Каждый ресурс (vm, firewall rules, metadata) описывается отдельным блоком resource и зависит от платформы запуска

ВАЖНО. Для GCP (и скорее всего для любой платформы) данные перезаписываются (т.е. если мы зальем через web-интерфейс ключи, и потом тоже самое через терраформ, то ключи добавленные через web-интерфейс будут удалены)

Когда развертываем инфраструктуру с балансировщиком, то самое оптимальное - использовать 