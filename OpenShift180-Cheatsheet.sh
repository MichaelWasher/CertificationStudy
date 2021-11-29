----- DO 180 Summary ------

---- Podman basics ----
podman images
podman run -d <image> <cmd>
podman run -it <image> <command>
podman run -e <env_var>=<value> --name <cont_name> <image>
podman ps -a

---- Executing Commands in a running Container ----
podman exec <cont_name> <command>
podman exec -l <command>
podman inspect <cont_name>

---- Managing Container State ----
podman start <cont_name>
podman stop <cont_name>
podman kill <cont_name>
podman restart <cont_name>
podman rm <cont_name>

---- Setup SELinux for Container Access ----
semanage fcontext -a -t container_file_t '/<folder>(/.*)?'
restorecon -Rv /<folder>
podman run -it -v /<folder>:<mount_path> <image>:<tag>

---- Podman Normal usage ----
podman run -d --name <cont_name> -p <host_port>:<cont_port> <image>:<tag>
podman port <cont_name>

---- Dealing with Registies ----
podman login -u <user> -p <pass> <url>
podman search <image-name>
podman pull <repository>/<image-name>:<tag>
podman search --limit <limit_number> <term>
podman search --tls-verify=false <term>
curl -Ls https://<registry>/v2/_catalog

--- Backup and Restore of Container ---
podman pull <registry>/<img>:<tag>
podman save -o <output_tar> <image>:<tag>
podman save -o <output_tar> <image>:<tag> --compress
podman load -i <input_tar> 

--- Managing Local Images ---
podman rmi
podman rmi -a
podman commit <container> <repository>/<image>:<tag>
podman diff <container>
podman tag <image>:<tag> <new_image>:<new_tag>
podman push <image> <destination>
podman build -t <image>:<tag> <directory>

--- Managing Pods ---
podman pod create
podman pod list
podman ps --pod
podman run -d --pod <podname> --name <cont_name> <image>:<tag>

---- Dockerfile Keywords ----
# Note the following are not BASH commands but is a Dockerfile example
FROM <image>:<tag>
LABEL description="value"
MAINTAINER Michael Washer <mwasher@redhat.com>
RUN yum install -y httpd
EXPOSE 80
ENV <env_var> <value>
ADD <URL> <cont_location>
COPY <host_location> <cont_location>
USER <user>
ENTRYPOINT ["<command>"]
CMD ["<arg1>", "<arg2>"]