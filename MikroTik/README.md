# MikroTik: домашний VPN через WireGuard для полных новичков

Эта инструкция для ситуации, когда дома стоит MikroTik, а вы хотите сделать так:

- обычные сайты открываются напрямую через провайдера;
- YouTube, Telegram, ChatGPT и другие нужные сервисы идут через VPN;
- все телефоны, ноутбуки, телевизоры и приставки дома используют это автоматически;
- на каждом устройстве отдельно VPN включать не нужно.

Пример роутера, под который писалась инструкция:

```text
MikroTik hAP ac
model: RB962UiGS-5HacT2HnT
RouterOS: 7.x
```

Но подход подходит и для других MikroTik на RouterOS 7, где есть WireGuard.

---

## Что мы будем делать простыми словами

У MikroTik будет два пути в интернет.

Первый путь — обычный интернет через провайдера.

Второй путь — VPN-туннель WireGuard через ваш сервер или Amnezia.

Дальше мы скажем роутеру:

```text
Если человек открывает обычный сайт — иди напрямую.
Если человек открывает Telegram / YouTube / ChatGPT — иди через VPN.
```

Это называется выборочная маршрутизация.

---

## Что нужно заранее

Перед началом нужно иметь:

1. MikroTik с RouterOS 7.
2. Доступ в MikroTik через WinBox или WebFig.
3. Уже созданный VPN-сервер в Amnezia или вручную.
4. WireGuard-конфиг формата `.conf`.
5. Файл `wireguard-install-template.rsc` из этой папки.
6. Файл `wireguard-cleanup.rsc` для отката, если что-то пошло не так.

---

## Важно: нужен именно WireGuard, не AmneziaWG

В Amnezia есть разные протоколы:

```text
WireGuard
AmneziaWG
OpenVPN
```

Для MikroTik нужен именно:

```text
WireGuard
```

Не `AmneziaWG`.

Почему так: MikroTik RouterOS умеет обычный WireGuard. AmneziaWG — это модифицированный WireGuard с дополнительными параметрами обфускации. В таком конфиге обычно есть строки:

```ini
Jc = ...
Jmin = ...
Jmax = ...
S1 = ...
S2 = ...
H1 = ...
H2 = ...
H3 = ...
H4 = ...
```

Если вы видите такие строки — это не тот конфиг для MikroTik.

---

## Как экспортировать WireGuard-конфиг из Amnezia

Откройте Amnezia на компьютере.

Зайдите в свой сервер.

Найдите кнопку:

```text
Поделиться
```

или:

```text
Share
```

или меню с тремя точками.

Дальше выберите:

```text
Экспорт конфигурации
```

И выберите именно:

```text
WireGuard
```

После этого сохраните файл `.conf`.

Откройте его обычным Блокнотом. Внутри должно быть примерно так:

```ini
[Interface]
Address = 10.8.1.2/32
DNS = 1.1.1.1, 1.0.0.1
PrivateKey = ВАШ_PRIVATE_KEY

[Peer]
PublicKey = PUBLIC_KEY_СЕРВЕРА
PresharedKey = PRESHARED_KEY_ЕСЛИ_ЕСТЬ
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 185.112.240.31:39373
PersistentKeepalive = 25
```

Нам из этого файла нужны только эти значения:

```text
Address
PrivateKey
PublicKey
PresharedKey
Endpoint IP
Endpoint port
```

---

## Важное предупреждение про ключи

Никогда не публикуйте в GitHub файл, где есть:

```text
PrivateKey
PresharedKey
```

Это как пароль от VPN.

В этот репозиторий можно класть только шаблон:

```text
wireguard-install-template.rsc
```

А файл с реальными ключами держите только у себя на компьютере.

---

## Файлы в этой папке

### `wireguard-install-template.rsc`

Это установочный шаблон. В нём нужно заменить несколько строк на значения из вашего WireGuard-конфига.

### `wireguard-cleanup.rsc`

Это откат. Он удаляет правила, которые создал установочный скрипт.

Если после настройки что-то пошло не так, загрузите cleanup-файл на MikroTik и выполните импорт.

---

## Шаг 1. Узнать свою локальную сеть

В MikroTik откройте Terminal и выполните:

```mikrotik
/ip address print
```

Ищите адрес на `bridge` или вашем LAN-интерфейсе.

Пример:

```text
192.168.0.1/24 interface=bridge
```

Это значит:

```text
адрес роутера: 192.168.0.1
локальная сеть: 192.168.0.0/24
```

Если у вас стандартный MikroTik, может быть так:

```text
192.168.88.1/24
```

Тогда локальная сеть будет:

```text
192.168.88.0/24
```

---

## Шаг 2. Скопировать шаблон

Скачайте файл:

```text
wireguard-install-template.rsc
```

Сделайте его копию у себя на компьютере и назовите, например:

```text
wireguard-install-ready.rsc
```

Именно этот файл мы будем редактировать.

---

## Шаг 3. Заполнить настройки в скрипте

Откройте `wireguard-install-ready.rsc` в Блокноте или любом редакторе.

В начале файла будет блок:

```mikrotik
:local lanSubnet "192.168.0.0/24"
:local routerDns "192.168.0.1"

:local wgPrivateKey "<PRIVATE_KEY_FROM_INTERFACE>"
:local wgAddress "10.8.1.2/32"

:local peerPublicKey "<PUBLIC_KEY_FROM_PEER>"
:local peerPresharedKey "<PRESHARED_KEY_FROM_PEER>"
:local endpointAddress "<ENDPOINT_IP>"
:local endpointPort 39373
```

Нужно заменить значения на свои.

---

## Шаг 4. Что куда вставлять

Берём из WireGuard `.conf`:

```ini
[Interface]
Address = 10.8.1.2/32
PrivateKey = abcdefg...

[Peer]
PublicKey = qwerty...
PresharedKey = zxcv...
Endpoint = 185.112.240.31:39373
```

И вставляем в MikroTik-скрипт:

```mikrotik
:local wgAddress "10.8.1.2/32"
:local wgPrivateKey "abcdefg..."

:local peerPublicKey "qwerty..."
:local peerPresharedKey "zxcv..."
:local endpointAddress "185.112.240.31"
:local endpointPort 39373
```

Если в вашем конфиге нет `PresharedKey`, оставьте строку пустой:

```mikrotik
:local peerPresharedKey ""
```

---

## Шаг 5. Проверить LAN-настройки

Если ваш MikroTik имеет адрес:

```text
192.168.0.1
```

то оставьте:

```mikrotik
:local lanSubnet "192.168.0.0/24"
:local routerDns "192.168.0.1"
```

Если ваш MikroTik имеет адрес:

```text
192.168.88.1
```

то поменяйте на:

```mikrotik
:local lanSubnet "192.168.88.0/24"
:local routerDns "192.168.88.1"
```

---

## Шаг 6. Загрузить файл в MikroTik

Откройте WinBox.

Подключитесь к роутеру.

Откройте раздел:

```text
Files
```

Перетащите туда файл:

```text
wireguard-install-ready.rsc
```

Файл должен появиться в списке файлов MikroTik.

---

## Шаг 7. Запустить установку

Откройте Terminal в WinBox.

Выполните:

```mikrotik
/import file-name=wireguard-install-ready.rsc
```

Если всё нормально, в конце будет сообщение:

```text
Done.
```

---

## Что создаёт скрипт

Скрипт создаёт:

```text
WireGuard-интерфейс: wg-vpn
таблицу маршрутизации: to_vpn
список адресов: vpn_sites
NAT через VPN
правило mangle для выборочной маршрутизации
```

Также скрипт отключает FastTrack.

Это важно: FastTrack ускоряет обычный трафик, но часто ломает выборочную маршрутизацию через `mangle`.

---

## Шаг 8. Проверить, что VPN поднялся

Выполните:

```mikrotik
/interface wireguard peers print detail where interface=wg-vpn
```

Ищите строку:

```text
last-handshake
```

Если `last-handshake` есть и время свежее — WireGuard подключился.

Если `last-handshake` пустой — туннель не поднялся.

---

## Шаг 9. Проверить, идёт ли трафик через VPN

Выполните:

```mikrotik
/interface monitor-traffic wg-vpn
```

Откройте YouTube или Telegram на телефоне/ноутбуке, подключенном к этому роутеру.

Если в `monitor-traffic` растут `rx` и `tx`, значит трафик пошёл через VPN.

---

## Шаг 10. Проверить правило выборочной маршрутизации

Выполните:

```mikrotik
/ip firewall mangle print stats where comment="auto-vpn selected sites via WireGuard"
```

Если счётчики растут, правило срабатывает.

---

## Как добавить свои сайты в VPN

Например, нужно добавить сайт:

```text
example.com
```

Выполните:

```mikrotik
/ip firewall address-list add list=vpn_sites address=example.com comment="auto-vpn"
```

Можно добавить IP-сеть:

```mikrotik
/ip firewall address-list add list=vpn_sites address=1.2.3.0/24 comment="auto-vpn"
```

---

## Как посмотреть весь список сайтов через VPN

```mikrotik
/ip firewall address-list print where list=vpn_sites
```

---

## Как временно отключить выборочный VPN

Отключить только правило маршрутизации:

```mikrotik
/ip firewall mangle disable [find where comment="auto-vpn selected sites via WireGuard"]
```

Включить обратно:

```mikrotik
/ip firewall mangle enable [find where comment="auto-vpn selected sites via WireGuard"]
```

---

## Как полностью удалить настройку

Загрузите в MikroTik файл:

```text
wireguard-cleanup.rsc
```

И выполните:

```mikrotik
/import file-name=wireguard-cleanup.rsc
```

Он удалит только то, что было создано этим комплектом.

---

## Если надо весь интернет через VPN

По умолчанию скрипт отправляет через VPN только выбранные сайты.

Если нужно отправить весь домашний интернет через VPN, можно добавить правило:

```mikrotik
/routing rule add src-address=192.168.0.0/24 action=lookup-only-in-table table=to_vpn comment="auto-vpn all LAN via WireGuard"
```

Если у вас сеть `192.168.88.0/24`, команда будет:

```mikrotik
/routing rule add src-address=192.168.88.0/24 action=lookup-only-in-table table=to_vpn comment="auto-vpn all LAN via WireGuard"
```

Удалить это правило:

```mikrotik
/routing rule remove [find where comment="auto-vpn all LAN via WireGuard"]
```

---

## Частые проблемы

### Нет `last-handshake`

Проверьте:

1. Правильно ли вставлен `PrivateKey`.
2. Правильно ли вставлен `PublicKey`.
3. Правильно ли вставлен `PresharedKey`, если он есть.
4. Правильно ли указан `Endpoint`.
5. Не перепутан ли порт.
6. Есть ли интернет на MikroTik.
7. Не заблокирован ли UDP-порт у провайдера.

Проверить доступность сервера можно так:

```mikrotik
/ping 185.112.240.31
```

Замените IP на свой сервер.

Важно: `ping` проверяет только доступность IP, но не проверяет UDP-порт WireGuard.

---

### Handshake есть, но сайты не открываются

Проверьте NAT:

```mikrotik
/ip firewall nat print where comment="auto-vpn masquerade to WireGuard"
```

Проверьте маршрут:

```mikrotik
/ip route print where routing-table=to_vpn
```

Проверьте mangle:

```mikrotik
/ip firewall mangle print stats where comment="auto-vpn selected sites via WireGuard"
```

---

### Telegram работает, YouTube нет

У YouTube много IP и CDN. Минимальные списки могут быть неполными.

Решение: добавить свежие IP-листы из проекта RockBlack-VPN/ip-address или добавить нужные домены вручную в `vpn_sites`.

---

### После настройки всё стало медленнее

Это нормально для старых роутеров.

hAP ac — хорошая железка, но не новая. WireGuard будет работать, но гигабит через VPN ждать не надо.

Если тариф быстрый, а через VPN нужна высокая скорость, лучше смотреть более мощные модели MikroTik.

---

### Почему отключился FastTrack

FastTrack может обходить часть firewall/routing-логики.

А нам нужно, чтобы MikroTik смотрел на адрес назначения и принимал решение: напрямую или через VPN.

Поэтому скрипт отключает FastTrack.

---

## Быстрый чек-лист

Перед запуском:

```text
[ ] Экспортирован именно WireGuard, не AmneziaWG
[ ] В скрипт вставлен PrivateKey
[ ] В скрипт вставлен PublicKey
[ ] В скрипт вставлен PresharedKey, если он есть
[ ] Endpoint разделён на IP и порт
[ ] Проверена локальная сеть: 192.168.0.0/24 или 192.168.88.0/24
[ ] Сделан backup MikroTik
[ ] Файл загружен в Files
[ ] Выполнен /import
```

После запуска:

```text
[ ] Есть last-handshake
[ ] Растёт трафик на wg-vpn
[ ] Растут счётчики mangle
[ ] Telegram/YouTube/ChatGPT открываются
[ ] Обычные сайты работают напрямую
```

---

## Команды проверки одним блоком

```mikrotik
/interface wireguard peers print detail where interface=wg-vpn
/interface monitor-traffic wg-vpn
/ip firewall mangle print stats where comment="auto-vpn selected sites via WireGuard"
/ip firewall address-list print where list=vpn_sites
/ip route print where routing-table=to_vpn
```

---

## Что можно коммитить в GitHub

Можно:

```text
MikroTik/README.md
MikroTik/wireguard-install-template.rsc
MikroTik/wireguard-cleanup.rsc
```

Нельзя:

```text
wireguard-install-ready.rsc с реальными ключами
полный export MikroTik
backup MikroTik
файлы с PPPoE-логинами и паролями
```
