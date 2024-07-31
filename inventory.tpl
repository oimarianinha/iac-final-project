[all]
${public_ip_address} ansible_user=${db_user} ansible_ssh_pass=${db_password} ansible_ssh_common_args='-o StrictHostKeyChecking=no'