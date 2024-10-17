#  Дипломная работа по профессии «Системный администратор»

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
 
---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  - для этого достаточно при создании ВМ указать name=example, hostname=examle !! 

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.

Настройка балансировщика:

1. Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

2. Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

3. Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

4. Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Исходящий доступ в интернет для ВМ внутреннего контура через [NAT-шлюз](https://yandex.cloud/ru/docs/vpc/operations/create-nat-gateway).

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

---

## Ход выполнения

## Terraform

Настройка и "подъем" инфраструктуры в Yandex Cloud осуществлялось с ипользованием terraform.
В целях безопасности параметры service_account, cloud_id и folder_id скрываем за переменными.
Конфигурацию полученной инфраструктуры проверяем коммандой terraform plan, и если нет ошибок, то комамандой terraform apply запускаем процесс развертывания инфраструктуры в облаке.
По заевершению процееса получаем данные output, которые ранее были прописаны в файле output.tf
```
FQDN_bastion = "bastion.ru-central1.internal"
FQDN_elastic = "elastic.ru-central1.internal"
FQDN_kibana = "kibana.ru-central1.internal"
FQDN_web-srv-1 = "web1.ru-central1.internal"
FQDN_web-srv-2 = "web2.ru-central1.internal"
FQDN_zabbix = "zabbix.ru-central1.internal"
external_ip_address_bastion = "158.160.9.73"
external_ip_address_kibana = "51.250.106.126"
external_ip_address_web-balancer = tolist([
  {
    "address" = "84.252.132.197"
  },
])
external_ip_address_zabbix = "158.160.68.80"
internal_ip_address_bastion = "10.128.4.15"
internal_ip_address_elastic = "10.128.3.10"
internal_ip_address_kibana = "10.128.4.11"
internal_ip_address_web-srv-1 = "10.128.1.10"
internal_ip_address_web-srv-2 = "10.128.2.10"
internal_ip_address_zabbix = "10.128.4.10"
```
На основании этих данный быыл сформирован файл инвентаря hosts для ansible

Проверяем созданную инфраструктуру

Созданы необходимые виртуальные машины
![Task1](img/ter1.jpg)

Создана сеть и 5 подсетей
![Task1](img/ter2.jpg)

Созданы группы безопасности
![Task1](img/ter3.jpg)

Создан балансировщик нагрузки web-balancer
![Task1](img/ter4.jpg)
![Task1](img/ter5.jpg)
![Task1](img/ter6.jpg)

Создано расписание снимков дисков
![Task1](img/ter7.jpg)

## Ansible
После команды ansible -m ping all убеждаюсь что все хосты доступны.
![Task2](img/dip1.jpg)

Используя playbook'и устанавливаем оснастку серверов.
![Task2](img/dip2.jpg)
![Task2](img/dip3.jpg)
![Task2](img/dip4.jpg)
![Task2](img/dip5.jpg)
![Task2](img/dip6.jpg)

## Доступность ресурсов

Проверяю доступность серверов с nginx через балансировщик
![Task3](img/ext1.jpg)

Проверка раотоспособности zabbix-сервера
![Task3](img/ext2.jpg)

Развернута Kibana, на которую приходят через Elasticsearch логи от веб-серверов
![Task3](img/ext3.jpg)
