# MikroTik RouterOS 7 hotfix: force all LAN traffic through existing WireGuard VPN
#
# Use this if selective YouTube routing does not work.
# It assumes that wireguard-install-template.rsc / wireguard-install-ready.rsc was already imported.
#
# Default LAN in this example: 192.168.0.0/24
# If your LAN is different, change lanSubnet before import.
#
# Import:
# /import file-name=wireguard-hotfix-all-lan-via-vpn.rsc

:local vpnName "wg-vpn"
:local routeTable "to_vpn"
:local lanSubnet "192.168.0.0/24"

# Put WireGuard into WAN interface-list if such list exists.
# Many firewall configs allow/deny traffic based on interface lists.
:if ([:len [/interface list find where name="WAN"]] > 0) do={
    :if ([:len [/interface list member find where list="WAN" and interface=$vpnName]] = 0) do={
        /interface list member add list="WAN" interface=$vpnName comment="auto-vpn WireGuard as WAN"
    }
}

# Disable FastTrack because it can bypass policy routing.
/ip firewall filter disable [find where action=fasttrack-connection]

# Add TCP MSS clamp for WireGuard.
# Helps when ping works but websites/video do not open because of MTU problems.
:if ([:len [/ip firewall mangle find where comment="auto-vpn clamp TCP MSS"]] = 0) do={
    /ip firewall mangle add chain=forward out-interface=$vpnName protocol=tcp tcp-flags=syn action=change-mss new-mss=clamp-to-pmtu passthrough=yes comment="auto-vpn clamp TCP MSS"
}

# Remove old test rule if it exists.
/routing rule remove [find where comment="auto-vpn all LAN via WireGuard"]

# Force whole LAN through VPN routing table.
/routing rule add src-address=$lanSubnet action=lookup-only-in-table table=$routeTable comment="auto-vpn all LAN via WireGuard"

# Flush connection tracking so old direct connections do not remain cached.
/ip firewall connection remove [find]

:log warning "auto-vpn hotfix enabled: all LAN traffic goes through WireGuard"
:put "Hotfix enabled: all LAN traffic goes through WireGuard."
:put "Check handshake: /interface wireguard peers print detail where interface=wg-vpn"
:put "Check traffic: /interface monitor-traffic wg-vpn"
:put "To disable: /routing rule remove [find where comment=\"auto-vpn all LAN via WireGuard\"]"
