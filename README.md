# router-vpn

[![Telegram](https://img.shields.io/badge/Telegram-Канал_Айти-2CA5E0?style=flat&logo=telegram)](https://t.me/aiti4biz)
[![AmneziaVPN](https://img.shields.io/badge/AmneziaVPN-amnezia.org-6C63FF?style=flat&logo=shield)](https://amnezia.org)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-устройства-00B5E2?style=flat&logo=openwrt)](https://openwrt.org/toh/start)
[![IP Lists](https://img.shields.io/badge/IP_листы-RockBlack--VPN-181717?style=flat&logo=github)](https://github.com/RockBlack-VPN/ip-address)
[![AmneziaWG OpenWrt](https://img.shields.io/badge/AmneziaWG_OpenWrt-пакеты-6C63FF?style=flat&logo=github)](https://github.com/amnezia-vpn/amneziawg-openwrt)

Эта история подразумевает что у вас есть уже платный VPS с настроенным OpenVPN где нить в Дании или купленый Амнезия и т.д.

**Инструкция как настроить домашний доступ для всей семьи VPN**
> 🆕 **Новичок? Начни отсюда:** [Полное руководство с нуля - выбор роутера, аренда VPS, установка туннеля](step-by-step.md)
---

## Оглавление
### С нуля
- [Полное руководство: выбор роутера, аренда VPS, установка туннеля, подключение к роутеру](step-by-step.md)
### OpenVPN
- [1. Выбор роутера](#1-выбор-роутера)
- [2. Общая схема сети](#2-общая-схема-сети)
- [3. Настройка на Keenetic (OpenVPN)](#3-настройка-на-keenetic)
  - [3.1. Включаем OpenVPN-клиент](#31-включаем-openvpn-клиент)
  - [3.2. Готовые списки IP](#32-готовые-списки-ip-youtube--telegram--chatgpt)
  - [3.3. Загрузка маршрутов](#33-загрузка-маршрутов-в-keenetic)
  - [3.4. Настройка DNS](#34-dns-чтобы-провайдер-не-ломал-резолв)
- [4. Настройка на Mi / OpenWrt (OpenVPN + AmneziaWG)](#4-настройка-на-mi--openwrt)
  - [4.1. Прошивка OpenWrt](#41-прошивка-openwrt-ax3000t--4a-и-тп)
  - [4.2. OpenWrt + OpenVPN](#42-openwrt--openvpn)
  - [4.3. OpenWrt + AmneziaWG](#43-openwrt--amneziawg)
- [5. Где брать листы IP и доменов](#5-где-брать-листы-ip-и-доменов)

### AmneziaWG
- [Keenetic + AmneziaWG](#1-keenetic--amneziawg-от-конфига-до-выборочного-роутинга)
  - [1.1. Подготовка Keenetic](#11-подготовка-keenetic)
  - [1.2. Получаем конфиг AmneziaWG](#12-получаем-конфиг-amneziawg)
  - [1.3. Импорт AmneziaWG в Keenetic](#13-импорт-amneziawg-в-keenetic)
  - [1.4. Добавляем ASC](#14-добавляем-asc-секретный-соус-amneziawg)
  - [1.5. Выборочный трафик](#15-выборочный-трафик-youtube--telegram--chatgpt)
  - [1.6. DNS для AmneziaWG](#16-dns-чтобы-провайдер-не-ломал-amneziawg-трафик)

---

## 1. Выбор роутера

### Keenetic (из DNS)

Смотри Wi-Fi-роутеры Keenetic с поддержкой актуального KeeneticOS и компонентом OpenVPN:

- Keenetic **Carrier KN-1721** - дешёвый рабочий вариант.
- Keenetic **Giga KN-1010/1011/1012** - мощнее, если тариф быстрый.
- Keenetic **Hopper, Viva, Extra, Titan** - любая свежая модель, где на сайте Keenetic доступна прошивка 4.x/5.x и в списке компонентов есть **OpenVPN client**.

В DNS они так и идут:
«Wi-Fi роутер Keenetic Giga», «Keenetic Hopper», «Keenetic Carrier» и т.п.

### Mi / другие под OpenWrt

Из того, что массово продаётся и нормально шьётся в OpenWrt 23.05+:

- **Xiaomi Router AX3000T**
- **Xiaomi Mi Router 4A Gigabit**
- **Mi Router 4C**

Главное: в таблице поддерживаемых устройств [OpenWrt](https://openwrt.org/toh/start) должна быть именно твоя модель и ревизия (там же лежат прошивки). Ревизия важна: одна и та же модель в v1 прошивается легко, а v3 - никак.

***

## 2. Общая схема сети

- Роутер провайдера (Ростелеком и т.п.) остаётся первым (даёт интернет, телефон, ТВ, не трогаем).
- За ним ставится **наш** роутер (Keenetic или OpenWrt), который:
    - поднимает VPN-туннель к зарубежному серверу,
    - по правилам отправляет в него только нужные сервисы.

Все телефоны/ПК/ТВ подключаются к нашему роутеру по Wi-Fi/кабелю.

***

## 3. Настройка на Keenetic

### 3.1. Включаем OpenVPN-клиент

1. **Управление -> Параметры системы -> Изменить набор компонентов.**
2. Отметь компонент **OpenVPN client** и установи.
3. После перезагрузки зайди в **Интернет -> Другие подключения**.
4. В блоке **VPN-подключения** нажми **Создать подключение** или **Загрузить из файла**.
5. Используем `.ovpn` от своего VPN-провайдера:
    - в окне настроек выбери тип **OpenVPN**;
    - либо вставь содержимое `.ovpn` в большое поле, либо укажи файл, если есть пункт «загрузить конфигурацию».
6. Сохрани. Включи подключение. Галочку **«использовать для выхода в интернет» не ставь** - нам нужен не основной канал, а «обходной путь».

Проверь в этом же окне, что подключение поднялось: есть внешний IP, идут «Отправлено/Принято».

***

### 3.2. Готовые списки IP (YouTube / Telegram / ChatGPT)

За IP-подсети отвечают готовые `.bat` файлы:

- Репозиторий: **RockBlack-VPN/ip-address** - https://github.com/RockBlack-VPN/ip-address
- Конкретные файлы - в разделе **Releases**:
    - `Global/Youtube/...youtube...bat`
    - `Global/Telegram/telegram.bat`
    - `Global/OpenAI/chatgpt.bat` (или аналогичный)

Скачай нужные `.bat` (они содержат команды статической маршрутизации для Keenetic).

***

### 3.3. Загрузка маршрутов в Keenetic

1. Открой **Сетевые правила -> Маршрутизация**.
2. Вверху нажми **«Загрузить из файла»**.
3. В выпадающем списке **Интерфейс** выбери **своё OpenVPN-подключение** (имя, которое ты дал, не Ethernet).
4. Укажи файл `youtube.bat` и нажми **Загрузить**.
5. Повтори для `telegram.bat` и `chatgpt.bat`.

Теперь все IP из этих файлов роутер будет вести не в обычный WAN, а через OpenVPN.

***

### 3.4. DNS, чтобы провайдер не ломал резолв

Если оставить DNS провайдера, он может «зарубить» запросы к YouTube/Telegram ещё до туннеля. Лечим так.

1. Зайди в **Интернет-фильтры -> Настройка DNS**.
2. В блоке **Серверы DNS** нажми **«Добавить сервер»**:
    - Тип: «По умолчанию»;
    - Адрес: `1.1.1.1` или `8.8.8.8` (или DNS твоего VPN);
    - Подключение: **твой OpenVPN**. Сохрани.
3. Для доменных правил (если в твоей версии KeenOS это отдельный блок / режим «Маршруты DNS»):
    - добавь правила с доменами:
        - `*.youtube.com`, `*.googlevideo.com`;
        - `*.telegram.org`;
        - `*.openai.com`;
    - в каждом выбирай DNS, привязанный к OpenVPN-интерфейсу.

Итого на Keenetic:

- обычный трафик - через провайдера,
- IP и DNS YouTube/Telegram/ChatGPT - через OpenVPN.

***

## 4. Настройка на Mi / OpenWrt

### 4.1. Прошивка OpenWrt (AX3000T / 4A и т.п.)

1. На сайте [openwrt.org/toh/start](https://openwrt.org/toh/start) найди страницу своей модели. Убедись, что твоя **ревизия** (v1, v2 и т.д.) есть в таблице.
2. Скачай **factory**-образ для OpenWrt 23.05.x или 24.10.x (для первой прошивки нужен именно factory, не sysupgrade).
3. Зайди в родной веб-интерфейс Xiaomi (обычно `192.168.31.1` или `miwifi.com`).
4. Найди раздел обновления прошивки и загрузи скачанный файл.
5. После перезагрузки зайди на `192.168.1.1` - увидишь LuCI (веб-интерфейс OpenWrt). Логин: `root`, пароль пустой (сразу установи его в **System -> Administration**).

> **Важно:** некоторые модели Xiaomi требуют предварительной разблокировки SSH через приложение Mi WiFi. Проверь инструкцию именно для своей модели на странице OpenWrt.

***

### 4.2. OpenWrt + OpenVPN

#### 4.2.1. Установка пакетов

Подключись к роутеру по SSH (логин `root`, адрес `192.168.1.1`) или используй **System -> Software** в LuCI:

```sh
opkg update
opkg install openvpn-openssl luci-app-openvpn
```

После установки в LuCI появится меню **VPN -> OpenVPN**. Перезагрузи страницу браузера, если меню не появилось.

#### 4.2.2. Импорт конфига и создание интерфейса

1. В LuCI: **VPN -> OpenVPN -> нажми «Add»**.
2. Дай имя инстансу (например, `vpn_de`), тип - **Custom configuration**.
3. Нажми **Edit** и вставь содержимое своего `.ovpn` файла целиком в текстовое поле. Сохрани.
4. Включи инстанс галочкой и нажми **Save & Apply**.
5. Перейди в **Network -> Interfaces -> Add new interface**:
    - Имя: `ovpn0`;
    - Протокол: **Unmanaged**;
    - Устройство: `tun0` (OpenVPN создаёт его автоматически при старте).
6. На вкладке **Firewall** у интерфейса `ovpn0` назначь зону `wan`. Сохрани.

#### 4.2.3. Проверка подключения

В SSH выполни:

```sh
ip addr show tun0
ping -I tun0 1.1.1.1 -c 3
```

Если `tun0` есть и пинг проходит - туннель работает.

#### 4.2.4. Выборочная маршрутизация через pbr

```sh
opkg update
opkg install pbr luci-app-pbr
```

В LuCI появится **Services -> Policy Routing**.

1. Включи сервис pbr.
2. В разделе **Interface Gateways** убедись, что `ovpn0` есть в списке (если нет - добавь вручную).
3. Включи опцию **Use resolver set support** (для маршрутизации по доменам через dnsmasq + nft/ipset).
4. В разделе **Policies** добавь правила:

| Имя | Destination address | Interface |
|---|---|---|
| youtube | `youtube.com googlevideo.com` | ovpn0 |
| telegram | `telegram.org t.me` | ovpn0 |
| openai | `openai.com chatgpt.com` | ovpn0 |

5. Нажми **Save & Apply**, затем **Restart** сервиса pbr.

> Если не хочешь использовать домены - скопируй IP-подсети из тех же `youtube.bat`/`telegram.bat` и вставь их в поле **Destination address** в pbr (по одной подсети на строку или через пробел).

#### 4.2.5. DNS на OpenWrt (OpenVPN)

1. В LuCI: **Network -> DHCP and DNS** (или **Network -> Interfaces -> Edit WAN -> Advanced Settings**).
2. В поле **DNS forwardings** (или **Use custom DNS servers**) пропиши `1.1.1.1` и `8.8.8.8`.
3. pbr с включённым **resolver set support** сам позаботится о том, чтобы DNS-запросы для нужных доменов уходили через `ovpn0`.

Итого: банки, Госуслуги, стриминги - напрямую. YouTube, Telegram, ChatGPT - через `ovpn0`.

***

### 4.3. OpenWrt + AmneziaWG

#### 4.3.1. Установка пакетов AmneziaWG

AmneziaWG - это WireGuard с параметрами обфускации (ASC). На OpenWrt требует отдельных пакетов:

```sh
opkg update
opkg install kmod-amneziawg amneziawg-tools luci-proto-amneziawg
```

> На некоторых сборках пакеты называются `kmod-awg` и `luci-proto-wireguard`. Если стандартные не находятся через `opkg`, добавь репозиторий amneziawg-openwrt по инструкции на [github.com/amnezia-vpn/amneziawg-openwrt](https://github.com/amnezia-vpn/amneziawg-openwrt).

После установки перезагрузи роутер:

```sh
reboot
```

#### 4.3.2. Получаем конфиг AmneziaWG

В приложении AmneziaVPN:

1. Открой нужный сервер (DE, PL и т.п.).
2. Нажми **Поделиться / Share -> Экспорт конфигурации -> AmneziaWG (.conf)**.
3. Сохрани файл (например, `de.conf`).

Открой `de.conf` в блокноте - там будут:

```ini
[Interface]
PrivateKey = <твой приватный ключ>
Address = 10.8.1.x/32
DNS = 1.1.1.1
Jc = 4
Jmin = 40
Jmax = 70
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4

[Peer]
PublicKey = <публичный ключ сервера>
Endpoint = x.x.x.x:51820
AllowedIPs = 0.0.0.0/0
```

Параметры `Jc`, `Jmin`, `Jmax`, `S1`, `S2`, `H1-H4` - это и есть ASC (обфускация).

#### 4.3.3. Создание интерфейса AmneziaWG в LuCI

1. **Network -> Interfaces -> Add new interface**.
2. Имя: `awg_de`.
3. Протокол: **AmneziaWG** (если пакеты установлены правильно, протокол появится в списке).
4. Заполни поля из конфига:
    - **Private Key** - значение `PrivateKey` из `[Interface]`;
    - **IP Addresses** - значение `Address` из `[Interface]`;
    - **Listen Port** - можно оставить пустым (случайный).
5. В блоке **AmneziaWG Settings** введи параметры обфускации из конфига:
    - Jc, Jmin, Jmax, S1, S2, H1, H2, H3, H4.
6. Перейди на вкладку **Peers**, нажми **Add peer**:
    - **Public Key** - значение `PublicKey` из `[Peer]`;
    - **Endpoint Host** - IP-адрес сервера из `Endpoint`;
    - **Endpoint Port** - порт из `Endpoint`;
    - **Allowed IPs** - `0.0.0.0/0` (весь трафик пойдёт через туннель, pbr потом разберёт);
    - **Persistent Keepalive** - `25`.
7. На вкладке **Firewall** назначь зону `wan`. Сохрани.
8. Нажми **Save & Apply**.

#### 4.3.4. Проверка туннеля AmneziaWG

В SSH:

```sh
awg show
```

Должен появиться интерфейс `awg_de` с последним хендшейком (latest handshake). Если хендшейка нет - проверь правильность ключей и ASC-параметров.

Дополнительная проверка:

```sh
ping -I awg_de 1.1.1.1 -c 3
```

#### 4.3.5. Выборочная маршрутизация через pbr

Установка pbr (если ещё не установлен):

```sh
opkg update
opkg install pbr luci-app-pbr
```

В LuCI: **Services -> Policy Routing**:

1. Включи сервис pbr.
2. В **Interface Gateways** добавь `awg_de`.
3. Включи **Use resolver set support**.
4. В **Policies** добавь правила:

| Имя | Destination address | Interface |
|---|---|---|
| youtube | `youtube.com googlevideo.com ytimg.com` | awg_de |
| telegram | `telegram.org t.me` | awg_de |
| openai | `openai.com chatgpt.com` | awg_de |

5. **Save & Apply** -> **Restart** pbr.

#### 4.3.6. DNS на OpenWrt (AmneziaWG)

Схема та же, что для OpenVPN:

1. **Network -> DHCP and DNS**: пропиши `1.1.1.1` и `8.8.8.8` в **DNS forwardings**.
2. pbr с **resolver set support** сам привяжет DNS-запросы нужных доменов к `awg_de`.

Итого: российский интернет и локальные сервисы - напрямую через провайдера. YouTube, Telegram, ChatGPT - через AmneziaWG-туннель.

***

## 5. Где брать листы IP и доменов

- Готовые IP-диапазоны в `.bat` под Keenetic и просто списками - репозиторий **RockBlack-VPN/ip-address**: https://github.com/RockBlack-VPN/ip-address (YouTube, Telegram, OpenAI и т.д.).
- Для более тонкой доменной маршрутизации на Keenetic - проект **keen-pbr** (скрипт с `dnsmasq` и ipset, если захочешь углубиться).
- Для OpenWrt - pbr умеет работать с доменами через свои resolver-sets, без ручного поиска подсетей.

---

## Полезные ссылки

| Ресурс | Ссылка | Зачем |
|---|---|---|
| Канал Айти (Telegram) | https://t.me/aiti4biz | Статьи и обсуждения |
| AmneziaVPN (сайт) | https://amnezia.org | Клиент и инструкция по VPS |
| AmneziaWG для OpenWrt | https://github.com/amnezia-vpn/amneziawg-openwrt | Пакеты AWG под OpenWrt |
| Таблица устройств OpenWrt | https://openwrt.org/toh/start | Проверить свою модель |
| IP-листы RockBlack-VPN | https://github.com/RockBlack-VPN/ip-address | bat-файлы маршрутов для Keenetic |
| pbr для OpenWrt | https://github.com/stangri/source.openwrt.melmac.net | Policy-based routing пакет |
| **Полный гайд с нуля** | [step-by-step.md](step-by-step.md) | Выбор роутера, VPS, установка туннеля |
---

**AmneziaWG**

---

## 1. Keenetic + AmneziaWG: от конфига до выборочного роутинга

### 1.1. Подготовка Keenetic

1. Обнови KeeneticOS до 4.2+ (в «Управление -> Обновление»).
2. В **Управление -> Параметры системы -> Изменить набор компонентов** включи компонент **WireGuard VPN**.
3. Роутер перезагрузится.

### 1.2. Получаем конфиг AmneziaWG

В приложении AmneziaVPN или в подписке:

1. Создаёшь сервер (страна DE/PL и пр.).
2. Нажимаешь **Поделиться / Export** -> **Конфигурация AmneziaWG (.conf)**.
3. Сохраняешь файл, например `de.conf`.
4. Внутри файла есть блок `[Interface]` и `[Peer]` плюс параметры `Jc/Jmin/Jmax/S1/S2/H1-H4` (ASC).

***

### 1.3. Импорт AmneziaWG в Keenetic

1. В роутере: **Интернет -> Другие подключения -> WireGuard**.
2. Нажми **«Загрузить из файла»**, выбери `*.conf`.
3. Появится подключение `de`. Войди в него, включи и поставь галку **«Использовать для выхода в интернет»** только если хочешь тестировать весь трафик через него; для выборочного сценария можно не ставить - мы будем работать через маршруты.

Проверка: в этом же окне должны расти счётчики «Принято/Отправлено».

***

### 1.4. Добавляем ASC (секретный соус AmneziaWG)

AmneziaWG - это WireGuard с дополнительными параметрами ASC, которые на Keenetic задаются через CLI.

1. Открой `de.conf` и выпиши:
    - Jc, Jmin, Jmax
    - S1, S2
    - H1, H2, H3, H4
2. В браузере открой Web-CLI Keenetic: в адресной строке `.../dashboard` замени на `/a`.
3. Введи `show interface Wireguard0` - убедись, что это твой конфиг.
4. Введи команду:

`interface Wireguard0 wireguard asc Jc Jmin Jmax S1 S2 H1 H2 H3 H4`

(цифры - строго из твоего конфига).
5. Сохрани конфиг:

`system configuration save`.

Для второго сервера (например, `pl`) повторяешь: импортируешь `pl.conf`, находишь `Wireguard1`, вводишь asc-строку и сохраняешь.

***

### 1.5. Выборочный трафик: YouTube / Telegram / ChatGPT -> например через de

С AmneziaWG дальше всё как с обычным WireGuard - Keenetic не видит разницы, маршрутизация такая же.

#### 1.5.1. IP-листы (bat-файлы)

Где брать:

- Репозиторий RockBlack-VPN: https://github.com/RockBlack-VPN/ip-address - там `.bat` и списки IP для YouTube, Telegram, OpenAI и т.п.
- Для AmneziaWG/keenetic есть ещё готовые наборы у BlackTemple и других провайдеров (часто дают прям ссылку «файлы маршрутизации для Keenetic»).

Берём, например:

- `Global/Youtube/...youtube...bat`
- `Global/Telegram/telegram.bat`
- `Global/OpenAI/chatgpt.bat`


#### 1.5.2. Загрузка маршрутов в de

1. **Сетевые правила -> Маршрутизация.**
2. Нажми **«Загрузить из файла»**.
3. В поле **Интерфейс** выбери **`de`** (имя твоего AmneziaWG-подключения, не Ethernet!).
4. Выбери `youtube.bat` -> Загрузить.
5. Повтори для `telegram.bat` и `chatgpt.bat`.

Теперь все IP из этих батников роутер гонит через `de`, остальное - как обычно через провайдера.

***

### 1.6. DNS, чтобы провайдер не ломал AmneziaWG-трафик

1. Зайди в **Интернет-фильтры -> Настройка DNS**.
2. В блоке **Серверы DNS**:
    - Добавь сервер `1.1.1.1` или `8.8.8.8`,
    - Подключение: `de`.
3. Если в твоей версии KeenOS есть блок DNS-маршрутов / доменных правил (как мы делали раньше):
    - добавь правила:
        - `*.youtube.com`, `*.googlevideo.com`;
        - `*.telegram.org`;
        - `*.openai.com`;
    - для каждого выбери DNS через `de`.

Результат: российский интернет живёт по-старому, а Ютуб/Телега/ChatGPT уходят в AmneziaWG-туннель.

***
