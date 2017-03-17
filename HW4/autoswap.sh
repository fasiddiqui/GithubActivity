#/bin/bash
if [[ $# -ne 1 ]]; 
    then echo "illegal number of parameters"
    exit
fi
cd nginx-rev
ngsha=`docker ps -a | grep proxy | sed -e 's: .*$::'`
docker exec -it $ngsha /bin/bash getconffile.sh >> temp
proxy=`awk 'NR==18' temp`
rm temp
proxyaddress=`echo $proxy | cut -d " " -f 2 | sed 's/.$//'`
echo $proxyaddress
if [[ "$proxyaddress" == "http://web1:8080/activity/;"  ]] || [[ "$proxyaddress" == "http://www.cs.ucdavis.edu;"  ]] ; then
	echo "switching from web1 to web2"
	web1sha=`docker ps -a | grep web1 | sed -e 's: .*$::'`
	echo "running web2"
	docker run -d -P --network ecs189_default --name web2 $1
	echo "sleeping for 10 seconds"
	sleep 10
	echo "executing swap2.sh"
	docker exec -it $ngsha /bin/bash swap2.sh
	echo "sleeping for 10 seconds"
	sleep 10
	docker rm $web1sha -f
else
	echo "switching from web2 to web1"
	web2sha=`docker ps -a | grep web2 | sed -e 's: .*$::'`
	echo "running web1"
	docker run -d -P --network ecs189_default --name web1 $1
	echo "sleeping for 10 seconds"
	sleep 10
	echo "executing swap1.sh"
	docker exec -it $ngsha /bin/bash swap1.sh
	echo "sleeping for 10 seconds"
	sleep 10
	docker rm $web2sha -f
fi




