# vagrant to setup vm
```
vagrant up
```

# ansible to deploy docker (password: vagrant)
```
ansible-playbook -i profiles/dev/hosts ./docker-playbook.yml -k -vvvv
```

# docker clone from
https://github.com/geerlingguy/ansible-role-docker
https://success.docker.com/article/using-systemd-to-control-the-docker-daemon

# test connect
```
docker -H 192.168.45.41:2375 info
```

# Docker in Docker

#### Dockerfile
https://github.com/docker-library/docker

#### docker client
https://download.docker.com/linux/static/stable/x86_64/

#### add follow config
```
ENV DOCKER_CHANNEL stable
ENV DOCKER_ARCH x86_64
ENV DOCKER_VERSION 18.09.8

RUN set -eux; \
	\
	if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${DOCKER_ARCH}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version
```
