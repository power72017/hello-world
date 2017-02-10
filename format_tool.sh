#!/bin/bash  
#dafasdf

DETEC_USB_DISC_FLG=0
DETEC_USB_DISC_DISCONNECT=1
DETEC_USB_DISC_MOUNT_FLG=0
DETEC_USB_DISC_FORMAT_FLG=0
DSIC_SIZE=0


MOUNT_POINT="/tmp/test_hd"
DISC_DEV_PATH="/dev/sdb"


Detec_usb_disc(){  
	while :;do  
		temp=`ls $DISC_DEV_PATH 2>/dev/null`
		
		
		
		if [[ -n $temp ]];then 
			echo "find hd in slot......"
			DETEC_USB_DISC_FLG=1
			break
		else
			DETEC_USB_DISC_FLG=0
#			echo "没有发现有硬盘插入......"
			sleep 1
		fi
	done 
}  



Detec_usb_disc_mounted(){  
	while :;do  
		temp=`mount | grep "$DISC_DEV_PATH on"`
		if [[ -n $temp ]];then 
			echo "mount hd......"
			DETEC_USB_DISC_MOUNT_FLG=1
		else
			DETEC_USB_DISC_MOUNT_FLG=0
			
		fi
	done 
}


Detec_usb_disc_disconnect(){  
	while :;do  
		temp=`ls $DISC_DEV_PATH 2>/dev/null`
		if [[ -n $temp ]];then 
#			echo "硬盘disconnect......"
			DETEC_USB_DISC_DISCONNECT=1
			
		else
			DETEC_USB_DISC_DISCONNECT=0
			break
		fi
	done 
}




do_cmd_times(){
   
  for ((i=0;i<10;i++));do

    ($1) 

    if [ $? -eq 0 ];then
	break
    fi

  done

}


do_cmd_times_delay(){
   
  for ((i=0;i<10;i++));do

    ($1) 

    if [ $? -eq 0 ];then
	break
    else
        sleep 1
    fi

  done

}





check_mount_point(){

#	if mountpoint -q $MOUNT_POINT
	temp=`df $DISC_DEV_PATH | grep "$DISC_DEV_PATH"`
	
	if [[ -n $temp ]];then
	   echo "mount hd"
	   return 1
	else
	   echo "no hd mount"
	   return 0
	fi

}




check_usb_hd_format(){  
	format=`df -T | grep "$DISC_DEV_PATH" | awk '{ print $2 }'`
	
	if [ "$format" == "ext4" ];then
		return 1
	else
		read -p " " temp2
		return 0
	fi
}



	

#	do_cmd_times 'echo ddddddddddddddddd'

#        exit
	

	do_cmd_times "umount $DISC_DEV_PATH" 2>/dev/null

	while :;do  
		Detec_usb_disc
		if [ $DETEC_USB_DISC_FLG -eq 1 ];then 
		    check_mount_point
			if [ $? -eq 1 ];then
				echo "umount hd..........."
				do_cmd_times 'umount $DISC_DEV_PATH' 2>/dev/null
			fi

			echo "start format hd..........."
			read -t 2 -n 10000 discard
#			while read -e -t 0.1; do : ; done


		for ((i=0;i<20;i++));do
			
			(echo "y" | mkfs.ext4 $DISC_DEV_PATH )

			if [[ $? -eq 1 ]];then
				umount $DISC_DEV_PATH 2>/dev/null
				echo "**umount $DISC_DEV_PATH******$?"
                                sleep 5
                                echo "mkfs.ext4 fail..........."
				continue
                        else
				break
			fi
                done

            		[[ -d $MOUNT_POINT ]] || mkdir $MOUNT_POINT

			  for ((i=0;i<10;i++));do

			    mount $DISC_DEV_PATH $MOUNT_POINT 

			    if [ $? -eq 0 ];then
				break
			    else
                                uumount $DISC_DEV_PATH 2>/dev/null 
				sleep 1
			    fi

			  done


			DSIC_SIZE=`df -h $DISC_DEV_PATH | awk 'END{ print $2 }'`
			
#			read -t 2 -n 10000 discard
			
			check_usb_hd_format
			
			format_result=$?
			
#			echo =======format is==$format_result



                      for ((i=0;i<10;i++));do
			umount $DISC_DEV_PATH 2>/dev/null
			    if [ $? -eq 0 ];then
#		                echo "--------10----$?--"  
				break
			    else
#		                echo "---------11---$?--" 
				sleep 1
			    fi
                      done
			
			
			if [ $format_result -eq 1 ];then

#				sleep 5
				echo -e "\033[32m format SUC,SIZE($DSIC_SIZE),PLS power off then chang hd\033[0m"
#				read -p " " temp1
				Detec_usb_disc_disconnect
				

				clear
			else
				echo -e "\033[31m ,format fail,SIZE($DSIC_SIZE),PLS form again\033[0m"
#				read -p " " temp2
				clear
			fi
			
			
#			rm -rf $MOUNT_POINT
			DETEC_USB_DISC_MOUNT_FLG=0
			
		fi

	done 
	
	
	
	
