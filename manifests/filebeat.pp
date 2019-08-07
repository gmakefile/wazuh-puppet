# Wazuh App Copyright (C) 2019 Wazuh Inc. (License GPLv2)
# Setup for Filebeat
class wazuh::filebeat (
  $filebeat_elasticsearch_ip = 'localhost',
  $filebeat_elasticsearch_port = '9200',
  $elasticsearch_server_ip = "\"${filebeat_elasticsearch_ip}:${filebeat_elasticsearch_port}\"",

  $filebeat_package = 'filebeat',
  $filebeat_service = 'filebeat',
  $filebeat_version = '7.2.0',
  $wazuh_app_version = '3.9.4_7.2.0',
  $wazuh_extensions_version = 'v3.9.4',
){

  package { 'Installing Filebeat...':
    ensure => $filebeat_version,
    name   => $filebeat_package,
  }

  file { 'Configure filebeat.yml':
    owner   => 'root',
    path    => '/etc/filebeat/filebeat.yml',
    group   => 'root',
    mode    => '0644',
    notify  => Service[$filebeat_service], ## Restarts the service
    content => template('wazuh/filebeat_yml.erb'),
  }

  exec { 'Installing wazuh-template.json...':
    path    => '/usr/bin',
    command => "curl -so /etc/filebeat/wazuh-template.json 'https://raw.githubusercontent.com/wazuh/wazuh/${wazuh_extensions_version}/extensions/elasticsearch/7.x/wazuh-template.json'",
    notify  => Service['filebeat']
  }

  exec { 'Installing filebeat module ...':
    path    => '/usr/bin',
    command => "curl -s https://packages-dev.wazuh.com/3.x/filebeat/wazuh-filebeat-0.1.tar.gz | tar -xvz -C /usr/share/filebeat/module",
    notify  => Service['filebeat']
  }

  class directory_tree {

    # or you can assign them to a variable and use them in the resource
    $whisper_dirs = [ '/usr/share/filebeat', '/usr/share/filebeat/module',
                      '/usr/share/filebeat/module/wazuh',
                    ]

    file { $whisper_dirs:
      ensure => 'directory',
      owner  => 'root',
      group  => 'wheel',
      mode   => '0755',
    }

  }

  service { 'filebeat':
    ensure => running,
    enable => true,
  }


}
