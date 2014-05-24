<<<<<<< HEAD
#!/bin/sh

i=1

ls /home/minix/img/* | while read image
do
	mv ${image} "$i.${image#*.}"
	i=`expr ${i} + 1`
=======
m_file=`find /data/music -type f -regex "/data/music/[0-9].*\.flac"`

${m_file} | while read line
do
	mv ${line} ${line#*-\ }
>>>>>>> 0bda756d68a2d5ab792ae24e3604c84945e91b26
done
