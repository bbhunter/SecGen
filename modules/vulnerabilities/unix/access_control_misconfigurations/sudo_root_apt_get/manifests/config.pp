class sudo_root_apt_get::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  # Purge sudoers.d directory, but leave sudoers file as it is
  class { 'sudo':
    config_file_replace => false,
  }
  # Allow all users to run /usr/bin/apt-get as root without a password
  sudo::conf { 'users_sudo_apt_get':
    ensure  => present,
    content => "ALL  ALL=(root) NOPASSWD: /usr/bin/apt-get *",
  }

  # Allow all users to run sudo -l without a password
  sudo::conf { 'users_sudo_list':
    ensure  => present,
    content => "ALL  ALL=(root) NOPASSWD: /usr/bin/sudo -l",
  }
  ::secgen_functions::leak_files { 'sudo-root-apt-get-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'sudo-root-apt-get-flag-leak',
  }
}
