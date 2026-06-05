# MikroTik RouterOS 7 WireGuard selective routing PUBLIC TEMPLATE
# Safe for GitHub: no real keys inside.
#
# What it does:
# - creates WireGuard interface wg-vpn
# - creates routing table to_vpn
# - adds NAT through WireGuard
# - disables FastTrack
# - adds address-list vpn_sites
# - sends only selected sites through VPN
#
# How to use:
# 1. Copy this file to your computer.
# 2. Rename copy to wireguard-install-ready.rsc.
# 3. Replace placeholders below with values from your WireGuard .conf file.
# 4. Upload file to MikroTik: WinBox -> Files.
# 5. Run in Terminal:
#    /import file-name=wireguard-install-ready.rsc

# =========================
# USER SETTINGS
# =========================

:local vpnName "wg-vpn"
:local routeTable "to_vpn"
:local addressList "vpn_sites"

# Change these two lines if your LAN is different.
# Example 1: router 192.168.0.1 -> lanSubnet 192.168.0.0/24, routerDns 192.168.0.1
# Example 2: router 192.168.88.1 -> lanSubnet 192.168.88.0/24, routerDns 192.168.88.1
:local lanSubnet "192.168.0.0/24"
:local routerDns "192.168.0.1"

# From [Interface]
:local wgPrivateKey "<PRIVATE_KEY_FROM_INTERFACE>"
:local wgAddress "10.8.1.2/32"

# From [Peer]
:local peerPublicKey "<PUBLIC_KEY_FROM_PEER>"
:local peerPresharedKey "<PRESHARED_KEY_FROM_PEER>"
:local endpointAddress "<ENDPOINT_IP>"
:local endpointPort 39373

:local disableFastTrack true
:local createBackup true

# =========================
# SAFETY CHECKS
# =========================

:if ($wgPrivateKey = "<PRIVATE_KEY_FROM_INTERFACE>") do={
    :error "Stop: replace wgPrivateKey with PrivateKey from [Interface]"
}

:if ($peerPublicKey = "<PUBLIC_KEY_FROM_PEER>") do={
    :error "Stop: replace peerPublicKey with PublicKey from [Peer]"
}

:if ($peerPresharedKey = "<PRESHARED_KEY_FROM_PEER>") do={
    :error "Stop: replace peerPresharedKey with PresharedKey from [Peer]. If your config has no PresharedKey, set peerPresharedKey to empty string."
}

:if ($endpointAddress = "<ENDPOINT_IP>") do={
    :error "Stop: replace endpointAddress with Endpoint host from [Peer]"
}

# =========================
# BACKUP
# =========================

:if ($createBackup = true) do={
    /system backup save name=before-wireguard-vpn
    /export file=before-wireguard-vpn
}

# =========================
# WIREGUARD INTERFACE
# =========================

:if ([:len [/interface wireguard find where name=$vpnName]] = 0) do={
    /interface wireguard add name=$vpnName mtu=1420 private-key=$wgPrivateKey comment="auto-vpn WireGuard interface"
} else={
    /interface wireguard set [find where name=$vpnName] mtu=1420 private-key=$wgPrivateKey comment="auto-vpn WireGuard interface"
}

:if ([:len [/ip address find where interface=$vpnName and address=$wgAddress]] = 0) do={
    /ip address add address=$wgAddress interface=$vpnName comment="auto-vpn WireGuard address"
}

# =========================
# WIREGUARD PEER
# =========================

:if ([:len [/interface wireguard peers find where interface=$vpnName and comment="auto-vpn server peer"]] > 0) do={
    :if ($peerPresharedKey = "") do={
        /interface wireguard peers set [find where interface=$vpnName and comment="auto-vpn server peer"] public-key=$peerPublicKey endpoint-address=$endpointAddress endpoint-port=$endpointPort allowed-address=0.0.0.0/0,::/0 persistent-keepalive=25s
    } else={
        /interface wireguard peers set [find where interface=$vpnName and comment="auto-vpn server peer"] public-key=$peerPublicKey preshared-key=$peerPresharedKey endpoint-address=$endpointAddress endpoint-port=$endpointPort allowed-address=0.0.0.0/0,::/0 persistent-keepalive=25s
    }
} else={
    :if ($peerPresharedKey = "") do={
        /interface wireguard peers add interface=$vpnName public-key=$peerPublicKey endpoint-address=$endpointAddress endpoint-port=$endpointPort allowed-address=0.0.0.0/0,::/0 persistent-keepalive=25s comment="auto-vpn server peer"
    } else={
        /interface wireguard peers add interface=$vpnName public-key=$peerPublicKey preshared-key=$peerPresharedKey endpoint-address=$endpointAddress endpoint-port=$endpointPort allowed-address=0.0.0.0/0,::/0 persistent-keepalive=25s comment="auto-vpn server peer"
    }
}

# =========================
# ROUTING TABLE AND ROUTE
# =========================

:if ([:len [/routing table find where name=$routeTable]] = 0) do={
    /routing table add name=$routeTable fib
}

:if ([:len [/ip route find where routing-table=$routeTable and dst-address=0.0.0.0/0 and comment="auto-vpn default route via WireGuard"]] = 0) do={
    /ip route add dst-address=0.0.0.0/0 gateway=$vpnName routing-table=$routeTable comment="auto-vpn default route via WireGuard"
}

# IPv6 route is intentionally not added.
# Your LAN is probably IPv4-based. Do not add IPv6 until you understand your IPv6 firewall.

# =========================
# NAT THROUGH VPN
# =========================

:if ([:len [/ip firewall nat find where chain=srcnat and out-interface=$vpnName and comment="auto-vpn masquerade to WireGuard"]] = 0) do={
    /ip firewall nat add chain=srcnat out-interface=$vpnName action=masquerade comment="auto-vpn masquerade to WireGuard"
}

# =========================
# FASTTRACK
# =========================

:if ($disableFastTrack = true) do={
    /ip firewall filter disable [find where action=fasttrack-connection]
}

# =========================
# DNS
# =========================

/ip dns set servers=1.1.1.1,1.0.0.1 allow-remote-requests=yes

:if ([:len [/ip dhcp-server network find where address=$lanSubnet]] > 0) do={
    /ip dhcp-server network set [find where address=$lanSubnet] dns-server=$routerDns
}

# =========================
# ADDRESS LISTS
# =========================

/ip firewall address-list remove [find where list=$addressList and comment="auto-vpn"]

# Telegram
/ip firewall address-list add list=$addressList address=91.108.4.0/22 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=91.108.8.0/22 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=91.108.12.0/22 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=91.108.16.0/22 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=91.108.20.0/22 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=91.108.56.0/22 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=149.154.160.0/20 comment="auto-vpn"

# YouTube / Google video common ranges
/ip firewall address-list add list=$addressList address=64.233.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=74.125.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=142.250.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=142.251.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=172.217.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=172.253.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=173.194.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=209.85.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=216.58.0.0/16 comment="auto-vpn"
/ip firewall address-list add list=$addressList address=216.239.0.0/16 comment="auto-vpn"

# OpenAI / ChatGPT and domain-based dynamic entries
/ip firewall address-list add list=$addressList address=openai.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=chatgpt.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=auth.openai.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=api.openai.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=telegram.org comment="auto-vpn"
/ip firewall address-list add list=$addressList address=t.me comment="auto-vpn"
/ip firewall address-list add list=$addressList address=youtube.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=www.youtube.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=googlevideo.com comment="auto-vpn"
/ip firewall address-list add list=$addressList address=ytimg.com comment="auto-vpn"

# =========================
# POLICY ROUTING
# =========================

/ip firewall mangle remove [find where comment="auto-vpn selected sites via WireGuard"]

/ip firewall mangle add chain=prerouting src-address=$lanSubnet dst-address-list=$addressList action=mark-routing new-routing-mark=$routeTable passthrough=no comment="auto-vpn selected sites via WireGuard"

# =========================
# DONE
# =========================

:log info "auto-vpn WireGuard selective routing finished"
:put "Done."
:put "Check handshake: /interface wireguard peers print detail where interface=wg-vpn"
:put "Check traffic: /interface monitor-traffic wg-vpn"
:put "Check mangle hits: /ip firewall mangle print stats where comment=\"auto-vpn selected sites via WireGuard\""
