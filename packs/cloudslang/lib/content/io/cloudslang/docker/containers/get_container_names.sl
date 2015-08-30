#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Retrieves a list of all the Docker container names.
#
# Inputs:
#   - docker_options - optional - options for the docker environment - from the construct: docker [OPTIONS] COMMAND [arg...]
#   - all_containers - optional - show all containers (both running and stopped) - Default: false, only running containers
#                    - any input that is different than empty string or false (as boolean type) changes its value to True
#   - host - Docker machine host
#   - port - optional - SSH port
#   - username - Docker machine username
#   - password - optional - Docker machine password
#   - private_key_file - optional - path to private key file
#   - character_set - optional - character encoding used for input stream encoding from target machine; Valid: SJIS, EUC-JP, UTF-8
#   - pty - optional - whether to use PTY - Valid: true, false
#   - timeout - optional - time in milliseconds to wait for command to complete - Default: 600000 ms (10 min)
#   - close_session - optional - if false SSH session will be cached for future calls during the life of the flow, if true the SSH session used will be closed; Valid: true, false
#   - agent_forwarding - optional - enables or disables the forwarding of the authentication agent connection
# Outputs:
#   - container_names - list of container names separated by space
#   - raw_output - unparsed return result from the machine
# Results:
#   - SUCCESS - successful
#   - FAILURE - otherwise
####################################################

namespace: io.cloudslang.docker.containers

imports:
  ssh: io.cloudslang.base.remote_command_execution.ssh

flow:
  name: get_container_names
  inputs:
    - docker_options:
        required: false
    - all_containers:
        default: false
    - ps_parameters:
        default: >
          '-a' if bool(all_containers) else ''
        overridable: false
    - host
    - port:
        required: false
    - username
    - password:
        required: false
    - private_key_file:
        required: false
    - character_set:
        required: false
    - pty:
        required: false
    - timeout:
        default: "'600000'"
    - close_session:
        required: false
    - agent_forwarding:
        required: false

  workflow:
    - get_containers:
        do:
          ssh.ssh_flow:
            - host
            - port:
                required: false
            - command:
                default: >
                  'docker ' + (docker_options + ' ' if bool(docker_options) else '') + 'ps ' + ps_parameters
                overridable: false
            - pty: "'false'"
            - username
            - password:
                required: false
            - privateKeyFile:
                default: private_key_file
                required: false
            - timeout
            - characterSet:
                default: character_set
                required: false
            - closeSession:
                default: close_session
                required: false
            - agentForwarding:
                default: agent_forwarding
                required: false
        publish:
          - container_names: >
              ' '.join(map(lambda line : line.split()[-1], filter(lambda line : line != '', returnResult.split('\n')[1:])))
          - raw_output: returnResult
  outputs:
    - container_names
    - raw_output
