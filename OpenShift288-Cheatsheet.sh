--------------- OpenShift 288 - Developer Exam - SummarySheet ---------------

---- Create Basics  ----
oc new-project <project>
oc new-app --name <name> --build-env <env_key>=<env_value> <pull_link> --context-dir=<git-dir>
oc new-app -i <image>:<tag> <name>
oc create configmap <name> --from-literal <key>=<value>
oc create secret generic <name> --from-literal <key>=<value>
oc create service external_name <service> --external_name <url>

---- Custom Pull Secrets ----
oc create secret docker-registry <secret_name> --docker-server <URL> --docker-username <reg_user> --docker-password <reg_password>
oc create secret generic <secret_name> --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type kubernetes.io/dockerconfigjson
oc secrets link default <secret_name> --for pull_link
oc secrets link builder <secret_name>

---- Expose the Image Registry Route -----
oc patch config cluster -n openshift-image-registry --type merge -p '{"spec":{"defaultRoute":true}}'

---- Allow users to Pull / Push Images ----
oc policy add-role-to-user system:image-puller <user> -n <project>
oc policy add-role-to-user system:image-pusher <user> -n <project>

---- Managing Images / ImageStreams ----
oc get is -n openshift
oc get istag -n openshift
oc import-image <is_name>:<is_tag> --confirm --from <registry>/<image>:<tag>

---- Managing Builds ----
oc start-build <bc_name>
oc start-build <bc_name> -F
oc cancel-build <bc_name>
oc delete bc/<bc_name>
oc delete build/<build_name>

---- Customizing Builds ----
oc set env bc/<bc_name> BUILD_LOGLEVEL="5"
oc set triggers bc/<bc_name> --from-gitlab
oc set triggers bc/<bc_name> --from-image=<project>/<image>:<tag>
oc set build-hook bc/<bc_name> --post-commit --command -- <command>
oc set build-hook bc/<bc_name> --post-commit --script="<script>"

---- Managing Probes ----
oc set probe dc/<dc_name> --readiness --get-url=<url> --period=<period>
oc set probe dc/<dc_name> --liveness --open=tcp=<port_id> --period=<seconds> --timeout-seconds=<seconds>
oc set probe dc/<dc_name> --liveness --get-url=<url> --initial-delay-seconds=<seconds> --success-threshold=<min> --failure-theshold=<min>

---- Templates ----
oc get templates -n openshift
oc process --parameters -n openshift <template>
oc get template <template-name> -o yaml | oc process -f - -p <param_name>=<param_value> | oc create -f -

---- Managing Deployment / Rollout ----
oc rollout latest dc/<dc_name>
oc rollout history dc/<dc_name>
oc rollout history dc/<dc_name> --revision=<revision_number>
oc rollout cancel dc/<dc_name>
oc rollout retry dc/<dc_name>
oc rollback dc/<dc_name>
oc set trigger dc/<dc_name> --from-config --remove
oc rollout latest <dc_name>

---- Custom S2i Builder Image ----
s2i create <image> <directory>
podman build -t <image_tag> <directory>
s2i build <src> <image> <tag> --as-dockerfile <uri>
podman build -t <app_name> <dockerfile_uri>
podman run -it -u <uid> <app_name>

---- Exposing Pods ----
oc expose <type>/<name>
oc expose svc/<svc_name>

---- ConfigMap / Secret Mounts ----
oc set env pod/<pod_name> --from secret/<secret_name>
oc set env <type>/<type_name> --from configmap/<cm_name>
oc set env deployment/<depl_name> --from secret/<secret_name> --prefix <prefix>
oc set volume <type>/<type_name> --add -t <type> -m <mount_path> --name <name> --configmap-name <cm_name>
oc set volume dc/<name> --add -t secret -m <mount_path> --name <name> --secret-name <secret_name>


---- Other Tools ----
skopeo inspect --creds <user>:<pass> <link>
skope inspect <URL | grep  "io.opeshift.s2i.scripts-url"
# Additional Labels
# io.k8s.display-name
# io.k8s.description
# io.openshift.expose-services
# io.openshift.tags
# io.openshift.s2i.scripts-url
# io.openshift.s2i.description