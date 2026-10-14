# Handoff du pilote

Lu en premier par le pilote suivant (voir le skill `pilot`). Commité directement sur `main` si le CLAUDE.md du projet l'autorise, sinon par des PR. Garde-le à jour.

_Dernière mise à jour : <date>, session de pilote <n> (<modèle>, <machine>) : <une ligne>._

## Machines

- <machine> : <RAM, cœurs>, combien de sous-agents à la fois, où est le checkout principal.

## État

Une ligne par élément de travail : branche, PR, statut (prompt écrit / sous-agent au travail / en relecture / en attente d'approbation / fusionné).

- Rien en cours.

## Décisions (utilisateur)

Des exigences, pas des suggestions. Datées.

- <date> : langue de la conversation avec l'utilisateur : <langue>.
- <date> : modèle des sous-agents : <modèle>.
- <date> : fichiers du pilote directement sur `main` : <oui / non, par des PR>.

## Suite

1. <ce qui reste, dans l'ordre>

## Notes sur les sous-agents

Ce qui s'est mal passé avec les sous-agents précédents et comment ça a été réglé (ce qui dure va dans les skills). Par agent : prompt, durée, appels d'outils.

- <prompt NN> : <durée>, <appels d'outils>, <ce qui a coûté du temps>.
