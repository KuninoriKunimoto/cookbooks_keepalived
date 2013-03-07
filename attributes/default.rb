default["keepalived"]["shared_address"] = true
default["keepalived"]["global"]["notification_emails"] = "alert@test.local"
default["keepalived"]["global"]["notification_email_from"] = "alert@#{node["domain"] || "test.local"}"
default["keepalived"]["global"]["smtp_server"] = "127.0.0.1"
default["keepalived"]["global"]["smtp_connect_timeout"] = 30
default["keepalived"]["global"]["router_id"] = node["fqdn"]
default["keepalived"]["global"]["router_ids"] = {}   # node name based mapping
default["keepalived"]["check_scripts"] = {}
default["keepalived"]["instance_defaults"]["state"] = "MASTER"
default["keepalived"]["instance_defaults"]["priority"] = 100
default["keepalived"]["instance_defaults"]["virtual_router_id"] = 10
default["keepalived"]["instances"] = {}
# for Virtual & Real Servers Settings.
default["keepalived"]["vs"]["web_tier"] = {
  :vs_listen_ip => '192.168.50.10',
  :vs_listen_port => '80',
  :delay_loop => 6,
  :lb_algo => 'wlc',
  :lb_kind => 'dr',
  :vs_protocol => 'tcp',
  :real_servers => [
    {'ip' => '192.168.50.11', 'port' => '80'},
    {'ip' => '192.168.50.12', 'port' => '80'}
  ]
}
# for VRRP Settings.
default["keepalived"]["vrrp"]["services"] = {
  :interface => 'eth0',
  :virtual_router_id => 1,
  :state => 'BACKUP',
  :noprempt => false,
  :priority => 100,
  :virtual_ipaddress => ['192.168.50.10'],
  :auth_type => 'pass',
  :auth_pass => 'mmm'
}
