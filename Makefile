#
#

GIT_REV := $(shell git rev-parse HEAD)

default: up

apply:
	terraform plan && terraform apply

down:
	terraform plan && terraform apply -var 'servers=0'

up:
	vagrant up

provision:
	vagrant provision

packer:
	packer validate packer.json
	packer build -var 'git_rev=$(GIT_REV)' packer.json

clean:
	vagrant destroy --force
	terraform destroy -force


# vim:ft=make
#
