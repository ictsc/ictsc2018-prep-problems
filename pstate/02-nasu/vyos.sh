# !/bin/bash

# init configuration
## シングルクォーテーションで囲まれているとエラーになるため取り除く
sed -i -e "s|'||g" /home/ictsc/config
## インタフェースに対し MAC アドレスを設定する行を除外
sed -i -e 's|^.*hw-id.*$||g' /home/ictsc/config

# inject configuration
wr=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
cat /home/ictsc/config | while read line
do
  $wr begin
  $wr $line
  $wr commit
  $wr end
done

# remove configuration file
rm /home/ictsc/config

# disable startup script
sed -i -e 's|^\(/root/.sacloud-api/startup.sh\)|#\1|g' /etc/rc.local