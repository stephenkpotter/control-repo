 class profile::app::fsbo {

  $iis_features = [
    'Web-Server',
    'Web-WebServer',
    'Web-Http-Redirect',
    'Web-Mgmt-Console',
    'Web-Mgmt-Tools',
  ]


iis_feature { $iis_features:
  ensure => 'present',
}


file { 'c:\\inetpub\\wwwroot\\famis':
  ensure => 'directory'
}
 
file { 'c:\\inetpub\\wwwroot\\famis\\portal':
  ensure => 'directory'
}


iis_application_pool { 'famis':
      ensure                  => 'present',
      state                   => 'started',
      managed_pipeline_mode   => 'Integrated',
      managed_runtime_version => 'v4.0',
      start_mode              => 'OnDemand',
      identity_type           => 'SpecificUser',
      user_name               => 'Administrator',
      password                => 'password',
}

iis_virtual_directory { 'famis\portal':
  ensure       => 'present',
  #application  => '/',
  physicalpath => 'c:\\inetpub\\wwwroot\\famis\\portal',
  sitename     => 'Default Web Site',
  user_name    => 'Administrator',
  password     => 'password',
  require      => Iis_Application_Pool['famis'],
  notify       => Exec['convert'],
}

exec { 'convert':
  command => 'ConvertTo-WebApplication "IIS:Sites\\Default Web Site\famis\portal" -ApplicationPool famis',
  unless => 'Get-WebApplication | findstr portal',
  provider => powershell,
  require => Iis_Virtual_Directory['famis\portal'],
}

}
