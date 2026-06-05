# MikroTik RouterOS 7 WireGuard selective routing cleanup
# Removes only objects created by wireguard-install-template.rsc / wireguard-install-ready.rsc
#
# How to use:
# 1. Upload this file to MikroTik: WinBox -> Files.
# 2. Run in Terminal:
#    /import file-name=wireguard-cleanup.rsc

:local vpnName "wg-vpn"
:local routeTable "to_vpn"
:local addressList "vpn_sites"

# Remove mangle policy rule.
/ip firewall mangle remove [find where comment="auto-vpn selected sites via WireGuard"]

# Remove optional all-LAN routing rule if user created it from README.
/routing rule remove [find where comment="auto-vpn all LAN via WireGuard"]

# Remove NAT rule.
/ip firewall nat remove [find where comment="auto-vpn masquerade to WireGuard"]

# Remove VPN address-list records created by this script.
/ip firewall address-list remove [find where list=$addressList and comment="auto-vpn"]

# Remove VPN route.
/ip route remove [find where routing-table=$routeTable and comment="auto-vpn default route via WireGuard"]

# Remove WireGuard peer.
/interface wireguard peers remove [find where interface=$vpnName and comment="auto-vpn server peer"]

# Remove WireGuard IP address.
/ip address remove [find where interface=$vpnName and comment="auto-vpn WireGuard address"]

# Remove WireGuard interface.
/interface wireguard remove [find where name=$vpnName and comment="auto-vpn WireGuard interface"]

# Remove routing table.
/routing table remove [find where name=$routeTable]

:log warning "auto-vpn WireGuard selective routing removed"
:put "Cleanup done."
:put "FastTrack was not re-enabled automatically. Enable it manually only after checking your firewall rules."
