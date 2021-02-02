class backup {
  file { "/usr/local/bin/backupd":
    ensure  => "present",
    mode    => 'u+x',
    content => "#!/bin/bash

originPath=\"/opt\"
backupPath=\"/backup\"
filePath=\"\${backupPath}/\$(date +'%m-%d-%H-%M')/service.backup\"

mkdir -p `dirname \${filePath}`

cd \${originPath}

tar -cvzf \${filePath} *.txt

chmod 400 \${filePath}

chown root:root \${filePath}

cd \${backupPath}

rm -rf `ls -t \${backupPath} | tail -n +11`
",
  }
  
  cron { 'backup':
    command => '/usr/local/bin/backupd',
    user    => 'root',
	hour    => '1',
	minute  => '0', 
  }
}

include backup
