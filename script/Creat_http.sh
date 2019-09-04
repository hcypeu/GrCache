#!/bin/sh
#creat date 2019-0828
clear

# 检查当前用户是否是 root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

#按任意键继续
get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
printf "
#######################################################################
#         Nginx-Reverse-Proxy-config(HTTP)                           #
#######################################################################
"
echo -e  "\033[44mPress any key to start...or Press Ctrl+c to cancel\033[0m\n"
char=`get_char`

#创建项目
    read -e -p "请输入平台名称;区分大小写(example: cp_bj): "  PROJECT

#全局配置
NGINX_DIR=/usr/local/nginx
UPNAME=$(cat /dev/urandom | head -n 10 | md5sum | head -c 32)

#输入第一个域名
    read -e -p "请输入需要添加的域名(example: www.example.com): " DOMAIN
    if [ -z "$(echo ${DOMAIN} | grep '.*\..*')" ]; then
      echo "${CWARNING}Your domain ${DOMAIN} is invalid! ${CEND}"
    else
      break
    fi

#判断配置文件是否存在   
    if [ -e "${NGINX_DIR}/conf/vhost/$PROJECT/${DOMAIN}.conf" ] && echo -e "${DOMAIN} in the Nginx already exist! \nYou can delete ${CMSG}${NGINX_DIR}/conf/vhost/$PROJECT/${DOMAIN}.conf${CEND} and re-create"; then
      exit
    else
      echo -e 你输入的域名为="\033[31m${DOMAIN} \033[0m\n"
    fi

#添加第二个域名
    echo -e "\033[44m如果不需要多域名直接回车\033[0m\n"	
    read -e -p "请输入更多的域名(example: www.example.com): " MORE_DOMAIN

#输入后端服务器+端口
    echo -e "\033[31m如果只有一台后端服务器，则两次输入同一ip;禁止为空\033[0m"
    read -e -p "请输入第一台后端服务器IP+端口(example: 1.1.1.1:80): " UPIP1
    read -e -p "请输入第二台后端服务器IP+端口(example: 1.1.1.2:80): " UPIP2

#创建nginx配置相关目录
    echo "创建相关目录中..."
    [ ! -d "${NGINX_DIR}/conf/ssl" ] && mkdir -p "${NGINX_DIR}/conf/ssl"
    [ ! -d "${NGINX_DIR}/conf/vhost" ] && mkdir -p "${NGINX_DIR}/conf/vhost"
    [ ! -d "${NGINX_DIR}/conf/vhost/$PROJECT" ] && mkdir -p "${NGINX_DIR}/conf/vhost/$PROJECT" && echo "#${PROJECT} Configuration Directory;" >> "${NGINX_DIR}/conf/vhost/index.conf" && echo "include ${NGINX_DIR}/conf/vhost/$PROJECT/*.conf;" >> "${NGINX_DIR}/conf/vhost/index.conf"
    [ ! -e "${NGINX_DIR}/conf/vhost/index.conf" ] && touch "${NGINX_DIR}/conf/vhost/index.conf"
    [ ! -d /data/wwwlogs ] && mkdir -p /data/wwwlogs
    [ ! -d /data/cache ] && mkdir -p /data/cache


    echo "配置创建中..."
    sleep 3


    cat > ${NGINX_DIR}/conf/vhost/$PROJECT/${DOMAIN}.conf << EOF
upstream $UPNAME {
    server $UPIP1 weight=10 max_fails=3 fail_timeout=45s max_conns=5000;
    server $UPIP2 weight=10 max_fails=3 fail_timeout=45s max_conns=5000;
    keepalive 32;
}
server {
    listen 80;
    server_name ${DOMAIN} ${MORE_DOMAIN};
    add_header Via \$hostname;
    access_log /data/wwwlogs/${DOMAIN}_nginx.log main;
    error_log /data/wwwlogs/error_nginx.log;
    if (\$host != $DOMAIN) {  return 301 \$scheme://$DOMAIN\$request_uri;  }
    add_header GR-Cache-Status \$upstream_cache_status;
    
    proxy_set_header Host \$server_name;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header REMOTE-HOST \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_http_version 1.1;
    proxy_set_header Connection '';
    location / {
        proxy_pass http://$UPNAME;
    }
    location ~ \.(js|css|tpl|txt|xml|html)$ {
        proxy_pass http://$UPNAME;
        gzip on;
        proxy_cache cache_one;
        proxy_cache_key '"\$host\$request_uri\$cookie_user"';
        proxy_ignore_headers X-Accel-Limit-Rate;
        proxy_ignore_headers Set-Cookie Cache-Control;
        proxy_cache_valid 200 304 3d;
        expires 3d;
    }
    location ~ \.(jpeg|jpg|png|svg|gif|m3u8|ts|mp3)$ {
        proxy_pass http://$UPNAME;
        gzip off;
        proxy_cache cache_one;
        proxy_cache_key '"\$host\$request_uri\$cookie_user"';
        proxy_ignore_headers X-Accel-Limit-Rate;
        proxy_ignore_headers Set-Cookie Cache-Control;
        proxy_cache_valid 200 304 10d;
        expires 10d;
    }
    location ~ \.(woff|woff2|eot|font|fon|ttf|otf|ttc)$ {
        proxy_pass http://$UPNAME;
        gzip off;
        proxy_cache cache_one;
        proxy_cache_key '"\$host\$request_uri\$cookie_user"';
        proxy_ignore_headers X-Accel-Limit-Rate;
        proxy_ignore_headers Set-Cookie Cache-Control;
        proxy_cache_valid 200 304 30d;
        expires 30d;
    }
}
EOF

$NGINX_DIR/sbin/nginx -t
$NGINX_DIR/sbin/nginx -s reload

echo -e "\033[32mAdded Configuration Successful ，请改hosts测试\033[0m"
#域名配置完成
printf "
    你的项目为: ${PROJECT}
    你添加的第1个域名为: ${DOMAIN}
    你添加的第2个域名为: ${MORE_DOMAIN}
    第一个后端IP为: ${UPIP1}
    第二个后端IP为: ${UPIP2}
"
