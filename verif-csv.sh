#!/bin/bash
declare -A projets_csv
#boucle pour verifier le csv
while IFS=, read -r project_name template_used || [ -n "$project_name" ]
do
    if [ "$project_name" == "PROJECT_NAME" ]; then
        continue
    fi
    projets_csv["$project_name"]=1
    if [ -d "INFRAS/$project_name" ]; then
        # Passer à la boucle suivante
        continue
    else
    curl -u bymack:116782c19aeae8a7b6db8cf85f45f16c21 "http://localhost:8080/job/deployer-infra/buildWithParameters?token=job-does-job&PROJECT_NAME=$project_name&TEMPLATE=$template_used"
    echo "création du projet $project_name avec l'infrastructure $template_used"
    fi
done < ACTUAL_INFRA.csv

#boucle pour verifier les dossiers
for dossier in INFRAS/*; do
    projet=${dossier#INFRAS/}
    if [[ ! ${projets_csv["$projet"]} ]]; then
    curl -u bymack:116782c19aeae8a7b6db8cf85f45f16c21 "http://localhost:8080/job/destroy-infra/buildWithParameters?token=job-does-job&PROJETNAME=$projet"
    echo "destruction du projet $projet"
    fi
done