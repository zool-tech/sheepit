FROM debian:buster-slim

ENV LANG=C.UTF-8 JAVA_HOME=/usr/share/java si_name="ztpub" si_pwd="zNeERVZUr8IF6v9KORXHnnzJJ72x2NyaSc6l49gF" si_cpu=0 si_mem=0 si_reqtime="0:00-23:59"
ENV PATH=$JAVA_HOME/bin:$PATH

# java install params
ARG	JAVA_VERSION_1=8u292
ARG	JAVA_VERSION_2=b10
ARG	JAVA_DOWNLOAD_URL=https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk${JAVA_VERSION_1}-${JAVA_VERSION_2}/OpenJDK8U-jre_x64_linux_${JAVA_VERSION_1}${JAVA_VERSION_2}.tar.gz

LABEL	maintainer="zooltech@qq.com"

#install dependency libs
RUN set -eux;\
	apt-get update && apt-get upgrade -y && apt-get install -yq --no-install-recommends ca-certificates p11-kit curl \
	# Blender dependencies
	libglu1-mesa \
	# Blender dependencies of other sheepit containers explained:
	# needed in the past:
	#	libsdl1.2debian
	#	libgl1-mesa-glx
	# libglu1-mesa deps:
	#	libxxf86vm1
	#	libxfixes3
	#	Dependency chain for both being
	#	libglu1-mesa -> libgl1 -> libglx0 -> libglx-mesa0
	# default-jre-headless (openjdk-11-jre-headless) deps:
	#	libfreetype6
	#	libxi6
	#	libxrender1
	&& rm -rf /var/lib/apt/lists/*;\
	curl -L $JAVA_DOWNLOAD_URL -o openjdk.tgz;\
	mkdir -p $JAVA_HOME /sheep/work;\
	tar --extract --file openjdk.tgz --directory "$JAVA_HOME" --strip-components 1 --no-same-owner;\
	rm -rf openjdk.tgz* $JAVA_HOME/src.zip $JAVA_HOME/demo $JAVA_HOME/sample;\
# https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
	find $JAVA_HOME/lib -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf;ldconfig;\
# create start script
	{	echo '#!/bin/bash'; \
		echo 'echo Checking for client updates...';\
		echo 'SHEEPIT_LATEST_URL=https://www.sheepit-renderfarm.com/media/applet/client-latest.php';\
		echo "latestVersion=\`curl --silent --head \${SHEEPIT_LATEST_URL} | grep -Po '(?i)content-disposition:.*filename=\"?(?-i)\Ksheepit-client-[\d\.]+\d'\`";\
		echo 'if [ ! -e work/${latestVersion}.jar ]; then';\
		echo 'echo Updating client...';\
		echo 'rm -f work/sheepit-client*.jar';\
		echo 'curl -L ${SHEEPIT_LATEST_URL} -o work/${latestVersion}.jar';\
		echo 'fi';\
		echo 'if [ ${si_cpu} -eq 0 ]; then';\
		echo 'si_cpu=`nproc`';\
		echo 'fi';\
		echo 'if [ ${si_mem} -gt 0 ]; then';\
		echo 'memsetting="-memory ${si_mem}"';\
		echo 'fi';\
		echo 'echo Starting client.';\
		echo 'java -jar work/${latestVersion}.jar -ui text -login ${si_name} -password ${si_pwd} -cores ${si_cpu} -request-time ${si_reqtime} -cache-dir /sheep/work ${memsetting}';\
	} > /sheep/start.sh;chmod +x /sheep/start.sh

WORKDIR /sheep

CMD ./start.sh