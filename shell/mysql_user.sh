#!/bin/bash
#

show_menu() {

cat << eof
   =============
     1. 查看用户权限
     2. 创建用户
     3. 退出
   =============
eof

}

show_user_priv() {
   read -p "Enter user name: " full_name

   name=$(echo $full_name | awk -F@ '{print $1}')
   host_name=$(echo $full_name | awk -F@ '{print $2}')

   result_number=$(mysql -uroot -e "select user,host from mysql.user where user='$name' and host='$host_name'" | wc -l)

   if [ $result_number -eq 2 ]; then
     echo "用户$full_name权限如下："
     mysql -uroot -e "show grants for '$name'@'$host_name'"
   else 
     echo "用户$full_name不存在 "
   fi
}


create_mysql_user() {
   read -p "Enter user name: " full_name

   name=$(echo $full_name | awk -F@ '{print $1}')
   host_name=$(echo $full_name | awk -F@ '{print $2}')

   result_number=$(mysql -uroot -e "select user,host from mysql.user where user='$name' and host='$host_name'" | wc -l)

   if [ $result_number -ne 2 ]; then
     echo "当前数据列表如下："
     mysql -uroot -e "show databases"
     echo

     while true; do
         read -p "选择数据库：" db_name
         result_number=$(mysql -uroot -e "use $db_name; show tables" | wc -l)
         if [ $result_number -le 1 ]; then
             echo "这是一个空白数据库，请重新选择"
             continue
         fi
         echo "数据库$db_name表如下："
         mysql -uroot -e "use $db_name; show tables"
         echo
         break
     done

     read -p "选择表：" tb_name
     echo

     echo "权限列表如下："
     echo -e "select\nupate\ninsert\ndelete\nall"
     read -p "选择权限：" priv
     echo

     read -p "输入用户密码：" password

     mysql -uroot -e "grant $priv on $db_name.$tb_name to '$name'@'$host_name' identified by '$password'"
     mysql -uroot -e "flush privileges"

     echo "done"
   else
     echo "用户$full_name已经存在"
   fi
}


show_menu
echo

while true; do
   read -p "输入你的选择：" choice
   case $choice in
     1)
       show_user_priv
       ;;
     2)
       create_mysql_user
       ;;
     3)
       exit 0
       ;;
     *)
       echo "输入错误"
       continue
       ;;
    esac
done
