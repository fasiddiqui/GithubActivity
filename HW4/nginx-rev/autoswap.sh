#/bin/bash
cd nginx-rev
proxy=`awk 'NR==18' nginx.conf`
proxyaddress=`echo $proxy | cut -d " " -f 2 | sed 's/.$//'`
ngsha=`docker ps -a | grep proxy | sed -e 's: .*$::'`
if [ "$proxyaddress" -eq "web1:8080/activity/"];then
	web1sha=`docker ps -a | grep web1 | sed -e 's: .*$::'`
	docker run -d -P --network ecs189_default --name web2 $1
	docker exec -it ngsha /bin/bash "cd /etc/nginx
	sed -e s?web1:8080/activity/?web2:8080/activity/? <nginx.conf > /tmp/xxx
	cp /tmp/xxx nginx.conf
	service nginx reload "
	docker rm $web1sha -f
else
	web2sha=`docker ps -a | grep web2 | sed -e 's: .*$::'`
	docker run -d -P --network ecs189_default --name web1 $1
	docker exec -it ngsha /bin/bash "cd /etc/nginx
	sed -e s?web2:8080/activity/?web1:8080/activity/? <nginx.conf > /tmp/xxx
	cp /tmp/xxx nginx.conf
	service nginx reload "
	docker rm $web2sha -f
fi




