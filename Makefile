FLEET_COMMANDER_PLAYBOOK=ansible/fleet-commander-playbook.yml

ANSIBLE_PLAYBOOK ?= $(shell which ansible-playbook)

.PHONY: all tags tasks check

all: check tags tasks

tags: $(ANSIBLE_PLAYBOOK)
	$(ANSIBLE_PLAYBOOK) --list-tags $(FLEET_COMMANDER_PLAYBOOK) > fleet-commander-tags.txt

tasks: $(ANSIBLE_PLAYBOOK)
	$(ANSIBLE_PLAYBOOK) --list-tasks $(FLEET_COMMANDER_PLAYBOOK) > fleet-commander-tasks.txt

check: $(ANSIBLE_PLAYBOOK)
	$(ANSIBLE_PLAYBOOK) --syntax-check $(FLEET_COMMANDER_PLAYBOOK)
