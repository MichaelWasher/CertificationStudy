--- Basic OpenShift Usage ---
oc login -u <username> -p <password> https://<api_url>:6443
oc whoami -t
oc get <type>
oc describe <type>/<type_name>
oc delete <type>/<type_name>
oc delete <type> --all
oc create -f <YAML_file>
oc edit <type>/<type_name>

--- Managing Projects / Apps ---
oc new-project <project_name>
oc delete project <project_name>
oc new-app --name <app_name> --docker-image <registry>/<image>:<tag>
oc new-app --name <app_name> --docker-image <registry>/<image>:<tag> -e <env_var>=<value> 

--- Managing Nodes ---
oc adm top nodes
oc describe node <node_name>
oc adm node-logs <node_name>
oc adm node-logs -u <systemd_unit> <node_name>
oc debug node/<node_name>

--- Managing Pods ---
oc logs pod/<pod_name>
oc logs --tail 3 -n <namespace> -c <container> <pod>
oc debug deployment/<depl_name> --as-root
oc rsh <pod_name>
oc cp <file> <pod_name>:<file_path>
oc port-forward <pod_name> <local_port>:<remote_port>
oc get pod --loglevel <verbosity_number>

---- Managing Deployments ----
oc scale --replicas 3 deployment/myapp

--- Authentication ---
export KUBECONFIG=/home/user/auth/kubeconfig && oc get nodes
oc --kubeconfig /home/user/auth/kubeconfig get nodes
oc delete secret kubeadmin -n kube-system

--- Create HTPasswd AuthProvider ---
oc get oauth cluster -o yaml > oauth.yaml
oc replace -f oauth.yaml
htpasswd -c -B -b /tmp/htpasswd student redhat123
htpasswd -b /tmp/htpasswd student redhat1234
oc create secret generic htpasswd-secret --from-file htpasswd=/tmp/htpasswd -n openshift-config

--- Secrets ---
oc extract secret/<secret_name>  --to <local_dir> --confirm
oc set data secret/<secret_name> --from-file <key>=<path> -n <namespace>
oc create secret generic <secret_name> --from-literal <key>=<secret1>
oc create secret tls secret-tls --cert <cert_path> --key /path-to-key

---- ConfigMap / Secret Mounts ----
oc set env pod/<pod_name> --from secret/<secret_name>
oc set env <type>/<type_name> --from configmap/<cm_name>
oc set env deployment/<depl_name> --from secret/<secret_name> --prefix <prefix>
oc set volume <type>/<type_name> --add -t <type> -m <mount_path> --name <name> --configmap-name <cm_name>
oc set volume dc/<name> --add -t secret -m <mount_path> --name <name> --secret-name <secret_name>
oc set volume deployment/<name>  --add --type secret --secret-name <secret_name> --mount-path <mount_path>

---- RBAC and Users ----
--- Identities ---
oc get identities
oc delete identity <provider>:<username>
--- Users / Groups ---

---- RBAC
oc adm policy add-cluster-role-to-user <cluster_role> <username>
oc adm policy remove-cluster-role-from-user <cluster_role> <username>
oc adm policy add-cluster-role-to-user cluster-admin <username>
oc adm policy remove-cluster-role-from-user cluster-admin <username>
oc adm policy who-can <command> <type>
oc adm policy who-can delete <type>
oc policy add-role-to-user <local_role> <username> -n <project>

oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
oc adm policy add-cluster-role-to-group --rolebinding-name self-provisioners self-provisioner system:authenticated:oauth

---- Groups
oc adm groups new <group_name>
oc adm groups add-users <group_name> <user>
oc adm policy add-cluster-role-to-group <cluster_role> <group>

---- Managing Networking ----
oc expose deployment/<depl_name>
oc expose service <service_name> --hostname <route_url>
oc expose service/<service_name> --port <port_id> --hostname <route_url>
oc create route passthrough <route_name> --service <svc_name> --port <port> --hostname <route_url>
oc create route edge <route_name> --service <svc_name> --port <port> --hostname <route_url> --ca-cert <ca_cert> --cert <cert>
oc get routes
oc get network/cluster -o yaml
oc describe deployment/frontend | grep Labels -A1
oc create route edge  --service <service> --hostname <route_url>  --key <cert_key> --cert <cert_key>
oc expose service hello
oc get networkpolicies -n network-policy

--- Security Context Constraints ---
oc get scc
oc describe scc anyuid
oc get pod <pod_name> -o yaml | oc adm policy scc-subject-review -f -

--- Service Accounts ---
oc create serviceaccount <service_account>
oc adm policy add-scc-to-user <scc_name> -z <service_account>
oc set serviceaccount deployment/<depl_name> <service_account>

--- Configure custom x509 Certificate ---
openssl genrsa -out <output_rsa_key_file.key> 2048
openssl x509 -req -in <csr_file.csr> -passin file:<password_file> -CA <CA_file.pem> -CAkey <CAkey_file.pem> -CAcreateserial -out <output_cert_file.crt> -days 1825 -sha256 -extfile <ext_file.ext>
openssl req -new -key <rsa_key_file.key> -out <csr_file.csr>
oc create secret tls <secret_name> --cert <cert_file> 
oc create route edge <route_name> --service <svc_name> --port <port> --hostname <route_url> --ca-cert <secret_ca_cert> --cert <secret_cert>

--- Dealing with Labels
oc label node node1.us-west-1.compute.internal <label>=<value>
oc label node node1.us-west-1.compute.internal env=prod --overwrite
oc label node node1.us-west-1.compute.internal env-
oc get node -L env

--- Using Labels for Constraints ---
oc adm new-project <project_name> --node-selector "<annotate>=<value>"
oc annotate namespace <namespace_name> openshift.io/node-selector="<annotate>=<value>" --overwrite

--- Managing Resources
oc set resources deployment <depl_name> --requests cpu=<vlaue>,memory=<value> --limits cpu=80m,memory=100Mi
oc adm top nodes -l node-role.kubernetes.io/worker
oc get resourcequota # cannot be created without yaml
oc get limitrange # cannot be created without yaml
oc create clusterquota user-qa --project-annotation-selector openshift.io/requester=qa --hard pods=12,secrets=20
oc create clusterquota env-qa --project-label-selector environment=qa --hard pods=10,services=5
oc adm create-bootstrap-project-template -o yaml > /tmp/project-template.yaml

---- Scaling an Application ----
oc get deployment
oc autoscale dc/hello --min 1 --max 10 --cpu-percent 80
oc get hpa

--- Cluster version ----
oc get clusterversion
oc adm upgrade --to-latest=true
oc adm upgrade --to=VERSION
oc get clusteroperators

--- Storage ---
oc set volumes deployment/<deployment> --add --name <mount_nam> --type pvc --claim-class <storage_class> --claim-mode rwo --claim-size <size> --mount-path <mount_path> --claim-name <pvc_name>
oc delete pvc/<pvc_name>