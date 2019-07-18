#!/bin/bash
### Checking for Firewall 1 to become available ###
while true
do
  echo "${fw1_mgmt_ip}" >> pan.log
  resp=$(curl -vvv -s -S -g --insecure "https://${fw1_mgmt_ip}")
  exit_code=$?
  if [ $exit_code -ne 0 ] ; then
    echo "Waiting..." >> pan.log
    echo "Waiting for Firewall 1 to start..."
  else
    echo "Firewall 1 has started!"
    break
  fi
  echo "Response $exit_code"
  sleep 10s
done
for i in `seq 1 30`
do
sleep 5
echo "Waiting for Firewall 1 API to start... "
done

### Confirm App/Threat and GlobalProtect Agent Bundle ###
echo "Confirm license installation"
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><license><fetch></fetch></license></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5

echo "Confirm GP Agent packages"
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><global-protect-client><software><check/></software></global-protect-client></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5

### Import GlobalProtect Agent Bundle ###
echo "Importing GlobalProtect Agent Bundle"
curl -k --form file=@PanGP-4.1.5 'https://${fw1_mgmt_ip}/api/?type=import&category=global-protect-client&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5

### Install GlobalProtect Agent Bundle ###
echo "Installing GlobalProtect Agent Bundle"
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><global-protect-client><software><activate><file>PanGP-4.1.5</file></activate></software></global-protect-client></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5

### Download and Install Latest App/Threat Updates ###
echo "Installing Latest App/Threat Updates"
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><content><upgrade><download><latest></latest></download></upgrade></content></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 60
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><content><upgrade><install><version>latest</version><commit>no</commit></install></upgrade></content></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5

### Download and Install AV Updates ###
echo "Installing Latest AV Updates"
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><anti-virus><upgrade><download><latest></latest></download></upgrade></anti-virus></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 60
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><anti-virus><upgrade><install><version>latest</version><commit>no</commit></install></upgrade></anti-virus></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5

### Download and Install WildFire Updates ###
echo "Installing Latest WildFire Updates"
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><wildfire><upgrade><download><latest></latest></download></upgrade></wildfire></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 60
curl -v -g -k 'https://${fw1_mgmt_ip}/api/?type=op&cmd=<request><wildfire><upgrade><install><version>latest</version><commit>no</commit></install></upgrade></wildfire></request>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0='
sleep 5


echo "GlobalProtect is now ready!"
echo "Firewall credentials:"
echo "Username: admin"
echo "Password: Pal0Alt0@123"
exit 0
